{ config, ...}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # Group that owns the nix config checkout (/srv/nix-conf).
  users.groups.nixadmins = { };

  # System-wide git trust for the checkout; ~/.config/git is read-only (home-manager).
  programs.git = {
    enable = true;
    config.safe.directory = [ "/srv/nix-conf" ];
  };

  users.users.hbarn = {
    isNormalUser = true;
    description = "barnabas hegedus";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "nixadmins" ];
  };

  users.users.hhinoki = {
    isNormalUser = true;
    description = "hhinoki";
    extraGroups = [ "networkmanager" "wheel" "nixadmins" ];
    initialPassword = "changeme"; # change with `passwd` after first login
  };

  # Setgid dir owned by nixadmins; `Z` recursively applies owner/group and
  # group-writable modes to the checkout on every activation.
  systemd.tmpfiles.rules = [
    "Z /srv/nix-conf 2775 root nixadmins -"
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;

  nix.settings = {
    # 24 lane CPU, max-jobs in parallel: 6, cores-per-jobs: 6 to limit memory deadlock without memory kill-limit
    max-jobs = 4;
    cores = 4;
    # Deduplicate the store by hard-linking identical files. Reduces /nix/store
    # size (esp. helpful given the small nvme). GC stays manual by choice.
    auto-optimise-store = true;
  };

  security.polkit.enable = true;
}
