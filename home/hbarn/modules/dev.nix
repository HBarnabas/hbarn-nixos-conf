{ pkgs, ... }:

{
  programs.vscode = {
    package = pkgs.vscode.fhs;
  };

  programs.git = {
    enable = true;
    settings.user = {
		  name = "HBarnabas";
		  email = "hbarnabas@outlook.com";
		};
  };
}
