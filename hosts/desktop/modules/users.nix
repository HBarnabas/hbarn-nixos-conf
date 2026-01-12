{ config, ...}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hbarn = {
    isNormalUser = true;
    description = "barnabas hegedus";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };


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
  };

  security.polkit.enable = true;
}
