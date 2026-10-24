{ pkgs, ... }:

{
  programs.vscode = {
    package = pkgs.vscode.fhs;
  };

  programs.git = {
    enable = true;
    # package = pkgs.git.override { withLibsecret = true; };
    settings.user = {
		  name = "HBarnabas";
		  email = "hbarnabas@outlook.com";
			# credential.helper = "libsecret";
		};
		signing.format = null;
		# lfs.enable = true;
  };
}
