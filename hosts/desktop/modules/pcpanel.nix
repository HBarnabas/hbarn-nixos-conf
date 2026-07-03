{ pkgs, ... }:

# PCPanel Mini (getpcpanel.com) support via the community driver:
# https://github.com/nvdweem/PCPanel
#
# The package (see `pkgs/pcpanel`, exposed via `overlays/pcpanel.nix`) is the
# repackaged upstream .deb. This module installs it and registers the udev
# rules that grant the logged-in user access to the device's hidraw node.
# Without the rules the device is detected but never opens
# ("Unable to open device ..." in the log).
{
  environment.systemPackages = [ pkgs.pcpanel ];

  # Picks up $out/lib/udev/rules.d/70-pcpanel.rules from the package.
  services.udev.packages = [ pkgs.pcpanel ];
}
