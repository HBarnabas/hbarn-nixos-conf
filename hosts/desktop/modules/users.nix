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

  security.polkit.enable = true;
}
