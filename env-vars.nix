{ config, pkgs, ... }:

{
  environment.sessionVariables = {
    WLR_OUTPUT="DP-1";
  };
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
}
