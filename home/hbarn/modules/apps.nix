{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utility
		keepassxc
		grim
    slurp
		mako
		wl-clipboard
		shotman
		btop
		mc
		curl
    wget
    vim
    htop
    tmux
    neofetch
    ntfs3g
    unzip
    memtester
    stress
    unrar

		# media
		pavucontrol
		spotify
		vlc
		gimp3

		# discord
		discord

		# dev
		sublime-merge
		vscode
		tenv # set TENV_AUTO_INSTALL=true
    tflint
    terraform-docs
    go-task
    jq
    inetutils
    vendir
    python311
    slack
    jdk8
    code-cursor
    zed-editor-fhs
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.dotnet_8.sdk
      dotnetCorePackages.dotnet_9.sdk
    ])
    (google-cloud-sdk.withExtraComponents( with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      kubectl
      docker-credential-gcr
    ]))

    #gaming
    gnome-sudoku
    deluge
    heroic
    wineWowPackages.stable
    winetricks
    (lutris.override {
      extraLibraries = pkgs: [
        geckodriver
      ];
    })

    # browser
    microsoft-edge

  ];
}
