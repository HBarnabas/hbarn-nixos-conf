final: prev: {
  ps4-pkg-tools = final.callPackage ../pkgs/ps4-pkg-tools/default.nix {
    # Keep this aligned with how you want it built system-wide.
    # Set to false if you want a CLI-only build.
    enableQt = true;

    # `wrapQtAppsHook` lives under `pkgs.qt6.*` in nixpkgs, so pass it explicitly.
    wrapQtAppsHook = final.qt6.wrapQtAppsHook;
  };
}
