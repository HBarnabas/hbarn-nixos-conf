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
, xdotool # optional focus-volume fallback on non-KDE X11; harmless otherwise
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

    # udev rules from linux.md: grant the logged-in user access to the
    # PCPanel's hidraw node (Mini/Pro/RGB vendor+product IDs).
    cat > $out/lib/udev/rules.d/70-pcpanel.rules <<'EOF'
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eb52", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c4", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c5", TAG+="uaccess"
    EOF

    # Wrap the jpackage launcher:
    # - pactl (pulseaudio package) for volume control against PipeWire-pulse
    # - xdotool for the optional non-KDE X11 focus-volume fallback
    # - LD_LIBRARY_PATH for libraries loaded via dlopen-by-soname at runtime,
    #   which autoPatchelf cannot fix in the ELF headers:
    #     * gtk3/libGL: JavaFX glass/prism (fails with "Internal Error" without gtk3)
    #     * libusb/udev: natives that hid4java extracts to /tmp
    #     * libx11/libxtst/libxkbcommon: natives that jnativehook extracts to /tmp
    # - the app expects its data dir (~/.pcpanel) to exist on first run
    makeWrapper $out/opt/pcpanel/bin/PCPanel $out/bin/pcpanel \
      --prefix PATH : ${lib.makeBinPath [ pulseaudio xdotool ]} \
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
