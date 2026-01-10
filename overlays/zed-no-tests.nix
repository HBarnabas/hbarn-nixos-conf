final: prev: {
  zed-editor = prev.zed-editor.overrideAttrs (old: {
    doCheck = false;
    cargoTestHook = "";
    checkPhase = "echo skipping tests";
  });
}
