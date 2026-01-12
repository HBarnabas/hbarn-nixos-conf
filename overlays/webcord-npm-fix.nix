final: prev: {
  webcord = prev.webcord.overrideAttrs (old: {
    # npm ci → strict, fails
    # npm install → lenient, works
    # npmFlags = [ "--legacy-peer-deps" ];
    # npmInstallFlags = [ "--legacy-peer-deps" ];

    # 2nd try
    npmConfigHook = "";
    npmInstallHook = "";
    npmBuildHook = "";

    configurePhase = "echo skipping configurePhase";
    patchPhase = "echo skipping patchPhase";

    # Force npm install instead of npm ci
    buildPhase = ''
      export HOME=$TMPDIR
      export npm_config_cache=$TMPDIR/npm-cache
      mkdir -p $npm_config_cache
      npm install --legacy-peer-deps
      npm run build
    '';

    installPhase = old.installPhase;
  });
}
