{ pkgs, ... }:

{
  # Plasma 6 session for hhinoki (launched via greetd's session-dispatch,
  # no SDDM — greetd remains the display manager).
  services.desktopManager.plasma6.enable = true;

  # KDE Connect isn't part of the plasma6 module; this installs it and
  # opens the firewall ports (1714-1764 TCP/UDP) it needs for discovery.
  programs.kdeconnect.enable = true;
}
