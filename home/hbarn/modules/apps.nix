{ pkgs, stable, ... }:

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
    whitesur-kde
    monado

		# media
		gimp3
		pavucontrol
		spotify
		vlc

		# chat
		discord
		# webcord # borked on 2026.01.08.

		# dev
		go
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
    wineWow64Packages.stable
    winetricks
    (lutris.override {
      extraLibraries = pkgs: [
        geckodriver
      ];
    })
    shadps4
    protonup-ng

    # browser
    # Pin Microsoft Edge stable to a known-good upstream .deb (the newer stable URLs were returning 404).
    (pkgs.microsoft-edge.overrideAttrs (old: rec {
      version = "144.0.3719.115";

      src = pkgs.fetchurl {
        url = "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${version}-1_amd64.deb";
        sha256 = "sha256-HoV2D51zxewFwwu92efEDgohu1yJf1UyjekO3YWZqPc=";
      };
    }))

  ];

  # protonup path - run protonup to download latest proton-ge
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
