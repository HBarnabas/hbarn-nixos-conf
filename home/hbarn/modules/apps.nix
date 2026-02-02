{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # utility
    btop
    curl
		grim
		htop
		keepassxc
    neofetch
    ntfs3g
    mako
		mc
    memtester
    shotman
		slurp
    stress
    tmux
    unrar
    unzip
    vim
    wget
    wl-clipboard
    wofi
    xournalpp

		# media
		gimp3
		pavucontrol
		spotify
		vlc

		# chat
		discord
		# webcord # borked on 2026.01.08.

		# dev
		code-cursor
		go-task
    inetutils
    jdk8
    jq
		python311
    slack
		sublime-merge
		tenv # set TENV_AUTO_INSTALL=true
    tflint
    terraform-docs
    vendir
    vscode
    (zed-editor-fhs.overrideAttrs (old: {
      doCheck = false;
      cargoAbout = null;
      cargoTestHook = "";
      checkPhase = "echo skipping tests";
      installCheckPhase = "echo skipping install checks";
      postBuild = "";
    }))
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.dotnet_8.sdk
      dotnetCorePackages.dotnet_9.sdk
    ])
    (google-cloud-sdk.withExtraComponents( with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      kubectl
      docker-credential-gcr
    ]))
    k9s
    kustomize
    kubernetes-helm
    postman

    #gaming
    deluge
    gnome-sudoku
    heroic
    wineWowPackages.stable
    winetricks
    (lutris.override {
      extraLibraries = pkgs: [
        geckodriver
      ];
    })
    shadps4

    # browser
    microsoft-edge

  ];
}
