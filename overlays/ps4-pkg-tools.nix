final: prev: {
  ps4-pkg-tools = final.callPackage ../pkgs/ps4-pkg-tools/default.nix {
    # Keep this aligned with how you want it built system-wide.
    # Set to false if you want a CLI-only build.
    enableQt = true;
  };
}
