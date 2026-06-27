{ lib
, appimageTools
, requireFile
}:

let
  pname = "fluxer-canary";
  version = "2026.602.31138";

  appimageName = "Fluxer_Canary-${version}-linux-x86_64.AppImage";

  # The AppImage is NOT committed to the repo. Instead it's referenced by hash
  # and must live in the Nix store. `requireFile` looks it up by hash; if it's
  # missing the build fails with the instructions in `message` below.
  #
  # To (re)provide the file for this exact version:
  #   nix-store --add-fixed sha256 /path/to/${appimageName}
  #
  # To update to a newer canary build:
  #   1. Download the new AppImage from https://fluxer.app/download
  #   2. Bump `version` above to match the new build.
  #   3. Update `hash` below to the new file's hash:
  #        nix hash file /path/to/<new>.AppImage
  #   4. Add it to the store with the `nix-store --add-fixed` command above.
  src = requireFile {
    name = appimageName;
    hash = "sha256-d4FAWwrWyoyp7lo8X+nIe+Dd6Z8rDThyK1wU00f7rjY=";
    message = ''
      The Fluxer Canary AppImage (${appimageName}) is required but not in the
      Nix store. Download it from https://fluxer.app/download and run:

        nix-store --add-fixed sha256 /path/to/${appimageName}
    '';
  };

  # Unpack so we can pull the .desktop entry and icon for desktop integration.
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Desktop entry + icon so Fluxer shows up in launchers (wofi/sway).
    install -Dm444 ${appimageContents}/fluxer-canary.desktop \
      $out/share/applications/fluxer-canary.desktop

    substituteInPlace $out/share/applications/fluxer-canary.desktop \
      --replace-warn 'Exec=AppRun --no-sandbox %U' 'Exec=fluxer-canary %U' \
      --replace-warn 'Exec=AppRun %U' 'Exec=fluxer-canary %U'

    install -Dm444 \
      ${appimageContents}/usr/share/icons/hicolor/512x512/apps/fluxer-canary.png \
      $out/share/icons/hicolor/512x512/apps/fluxer-canary.png
  '';

  meta = {
    description = "Fluxer (Canary) - instant messaging and VoIP chat app";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "fluxer-canary";
  };
}
