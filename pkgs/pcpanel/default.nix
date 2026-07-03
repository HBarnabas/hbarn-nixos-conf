{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, copyDesktopItems
, makeDesktopItem

  # Libraries the bundled JRE / launcher / JavaFX need at runtime.
, alsa-lib
, atk
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libGL
, libusb1
, libx11
, libxext
, libxi
, libxkbcommon
, libxrender
, libxtst
, libxxf86vm
, pango
, udev
, zlib

  # Runtime tools invoked by the app.
, pulseaudio # provides `pactl` (works against PipeWire's pulse server)
, xdotool # focus-volume backend on X11; wrapped by a sway shim (see below)
, jq # used by the sway xdotool shim to parse the sway IPC tree
, procps # real `ps`, wrapped by a shim that un-truncates process names
, coreutils # readlink, for the ps shim
}:

stdenv.mkDerivation rec {
  pname = "pcpanel";
  version = "1.7.1";

  src = fetchurl {
    url = "https://github.com/nvdweem/PCPanel/releases/download/v${version}/pcpanel_${version}_amd64.deb";
    hash = "sha256-Uy7sx5l2eM6qYDhVCTNAL/vItaECSY8x5qityu574KI=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libusb1
    libx11
    libxext
    libxi
    libxrender
    libxtst
    libxxf86vm
    pango
    stdenv.cc.cc.lib
    udev
    zlib
  ];

  # The bundled JRE dlopen()s some of these instead of linking them, and
  # hid4java extracts its own libhidapi at runtime, so don't fail on them.
  # GTK2 is gone from nixpkgs; JavaFX uses the GTK3 glass backend by default,
  # so the unused libglassgtk2.so deps are safe to ignore.
  autoPatchelfIgnoreMissingDeps = [
    "libjvm.so"
    "libawt.so"
    "libawt_xawt.so"
    "libjava.so"
    "libgtk-x11-2.0.so.0"
    "libgdk-x11-2.0.so.0"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share/pixmaps $out/lib/udev/rules.d
    cp -r opt/pcpanel $out/opt/pcpanel

    # Icon for the desktop entry.
    cp $out/opt/pcpanel/lib/PCPanel.png $out/share/pixmaps/pcpanel.png

    # udev rules based on linux.md, extended for NixOS: the app's HID layer
    # (hid4java) uses the libusb backend, which opens the raw USB node under
    # /dev/bus/usb (not the hidraw node). That node is 0664 root:root by
    # default (read-only for users), so without the SUBSYSTEM=="usb" rules the
    # device is detected but can't be opened and its serial reads as null
    # (NullPointerException in DeviceScanner). Covers Mini/Pro/RGB IDs.
    cat > $out/lib/udev/rules.d/70-pcpanel.rules <<'EOF'
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eb52", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c4", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c5", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eb52", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c4", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c5", TAG+="uaccess"
    EOF

    # xdotool shim that makes the "focus volume" feature work on sway/swayfx
    # (native Wayland). PCPanel 1.7.1 (LinuxProcessHelper) determines the
    # focused application with exactly two calls:
    #   xdotool getactivewindow          -> window id (one line)
    #   xdotool getwindowpid <windowid>  -> pid (one line)
    # and then resolves the pid to a process name via `ps -o comm=`. The real
    # xdotool only sees XWayland windows, so we answer those two subcommands
    # from the sway IPC tree instead and delegate everything else (and non-sway
    # sessions) to the real xdotool.
    mkdir -p $out/libexec/pcpanel
    cat > $out/libexec/pcpanel/xdotool <<'EOF'
    #!${stdenv.shell}
    if [ -n "$SWAYSOCK" ] && command -v swaymsg >/dev/null 2>&1; then
      case "$1" in
        getactivewindow)
          id=$(swaymsg -t get_tree | ${jq}/bin/jq -r 'first(.. | objects | select(.focused? == true) | .id) // empty')
          [ -n "$id" ] || exit 1
          printf '%s\n' "$id"
          exit 0
          ;;
        getwindowpid)
          [ -n "$2" ] || exit 1
          pid=$(swaymsg -t get_tree | ${jq}/bin/jq -r --argjson id "$2" 'first(.. | objects | select(.id? == $id) | .pid) // empty')
          [ -n "$pid" ] || exit 1
          printf '%s\n' "$pid"
          exit 0
          ;;
      esac
    fi
    exec ${xdotool}/bin/xdotool "$@"
    EOF
    chmod +x $out/libexec/pcpanel/xdotool

    # ps shim: after finding the focused pid, PCPanel resolves the process
    # name with `ps -p <pid> -o comm=` and matches it against the pulse
    # stream's application.process.binary / application.name. But comm is
    # kernel-truncated to 15 chars, so long binary names never match (e.g.
    # Spotify on Nix: comm .spotify-wrappe vs binary .spotify-wrapped).
    # Answer that exact query with the untruncated binary basename instead
    # (via /proc/pid/exe, falling back to /proc/pid/cmdline argv[0] for
    # non-dumpable processes like Chromium/crashpad apps whose exe link is
    # unreadable), and delegate anything else to the real ps.
    cat > $out/libexec/pcpanel/ps <<'EOF'
    #!${stdenv.shell}
    if [ $# -eq 4 ] && [ "$1" = -p ] && [ "$3" = -o ] && [ "$4" = "comm=" ]; then
      exe=$(${coreutils}/bin/readlink -f "/proc/$2/exe" 2>/dev/null)
      if [ -z "$exe" ] && [ -r "/proc/$2/cmdline" ]; then
        IFS= read -r -d "" exe < "/proc/$2/cmdline" || true
      fi
      if [ -n "$exe" ]; then
        name=''${exe##*/}
        printf '%s\n' "''${name%" (deleted)"}"
        exit 0
      fi
    fi
    exec ${procps}/bin/ps "$@"
    EOF
    chmod +x $out/libexec/pcpanel/ps

    # Wrap the jpackage launcher:
    # - pactl (pulseaudio package) for volume control against PipeWire-pulse
    # - the xdotool + ps shims (sway-aware / untruncated names) for focus volume
    # - LD_LIBRARY_PATH for libraries loaded via dlopen-by-soname at runtime,
    #   which autoPatchelf cannot fix in the ELF headers:
    #     * gtk3/libGL: JavaFX glass/prism (fails with "Internal Error" without gtk3)
    #     * libusb/udev: natives that hid4java extracts to /tmp
    #     * libx11/libxtst/libxkbcommon: natives that jnativehook extracts to /tmp
    # - the app expects its data dir (~/.pcpanel) to exist on first run
    makeWrapper $out/opt/pcpanel/bin/PCPanel $out/bin/pcpanel \
      --prefix PATH : $out/libexec/pcpanel:${lib.makeBinPath [ pulseaudio ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk3 libGL libusb1 udev libx11 libxtst libxkbcommon ]} \
      --run 'mkdir -p "''${PCPANEL_ROOT:-$HOME/.pcpanel}"'

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "pcpanel";
      exec = "pcpanel";
      icon = "pcpanel";
      desktopName = "PCPanel";
      comment = "Controller software for PCPanel devices";
      categories = [ "AudioVideo" "Audio" "Settings" ];
    })
  ];

  meta = {
    description = "Community controller software for PCPanel (getpcpanel.com) devices";
    homepage = "https://github.com/nvdweem/PCPanel";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "pcpanel";
  };
}
