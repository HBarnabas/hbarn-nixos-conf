{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [
	geckodriver
      ];
    })
    wineWowPackages.stable
    winetricks
  ];
}
