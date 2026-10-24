{ appimageTools, buildFHSEnv, stdenvNoCC, fetchurl, lib }:

let
  pname = "rpcs3";
  version = "0.0.43";

  src = fetchurl {
    # Check the latest URL and hash on https://rpcs3.net/download
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-5935028e1626606ccee26f2b5cfe5052c277a84b/rpcs3-v0.0.43-20353-5935028e_linux64.AppImage";
    hash = "sha256-mYQ+TJHO18Sr4L2ScxhrKqSkr+KcZaGrDUG2tiJGE7k=";
  };

  # RPCS3 AppImages use DwarFS rather than squashfs, so nixpkgs' appimageTools
  # can't extract them. The AppImage's own runtime can.
  contents = stdenvNoCC.mkDerivation {
    pname = "${pname}-appimage-contents";
    inherit version src;
    dontUnpack = true;
    installPhase = ''
      cp $src rpcs3.AppImage
      chmod +x rpcs3.AppImage
      ./rpcs3.AppImage --appimage-extract
      cp -rL squashfs-root $out
    '';
  };
in
buildFHSEnv (appimageTools.defaultFhsEnvArgs // {
  name = pname;
  # Run the binary directly; AppRun's checkrt hooks aren't needed on NixOS.
  runScript = "env LD_LIBRARY_PATH=${contents}/usr/lib ${contents}/usr/bin/rpcs3";

  # Host libraries the AppImage expects from the system.
  targetPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs) ++ (with pkgs; [
    alsa-lib
    e2fsprogs
    fontconfig
    freetype
    gmp
    libdrm
    libevdev
    libgpg-error
    libglvnd
    libice
    libpulseaudio
    libsm
    libusb1
    libx11
    libxcb
    udev
    vulkan-loader
    wayland
  ]);

  extraInstallCommands = ''
    install -Dm644 ${contents}/rpcs3.desktop $out/share/applications/rpcs3.desktop
    cp -r ${contents}/usr/share/icons $out/share/

    # Controller udev rules (DS3/DS4/DualSense), as in the nixpkgs package.
    install -Dm644 ${./99-ds3-controllers.rules} $out/etc/udev/rules.d/99-ds3-controllers.rules
    install -Dm644 ${./99-ds4-controllers.rules} $out/etc/udev/rules.d/99-ds4-controllers.rules
    install -Dm644 ${./99-dualsense-controllers.rules} $out/etc/udev/rules.d/99-dualsense-controllers.rules
  '';

  meta = {
    description = "PS3 emulator/debugger";
    homepage = "https://rpcs3.net/";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rpcs3";
  };
})
