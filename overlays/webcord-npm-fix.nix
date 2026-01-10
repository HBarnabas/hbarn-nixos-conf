final:prev: {
  webcord = prev.webcord.overrideAttrs (old: {
    # npm ci → strict, fails
    # npm install → lenient, works
    npmFlags = [ "--legacy-peer-deps" ];
    npmInstallFlags = [ "--legacy-peer-deps" ];

    # Force npm install instead of npm ci
    buildPhase = ''
      export HOME=$TMPDIR
      npm install --legacy-peer-deps
      npm run build
    '';
  })
}
