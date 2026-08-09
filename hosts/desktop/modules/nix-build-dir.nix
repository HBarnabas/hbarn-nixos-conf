{ lib, ... }:

# Move Nix's *build scratch space* off the small nvme (shared by /nix and /tmp)
# and onto the large HDD. This is what fills up during big compiles (kernel,
# webkit, chromium, llvm, ...): sources are unpacked and object files are
# written under `build-dir` (defaults to TMPDIR = /tmp) before the final,
# usually much smaller, result is copied into /nix/store.
#
# NOTE: this does NOT move /nix/store itself. If an update simply adds tens of
# GB of *new* store paths, run `sudo nix-collect-garbage -d` to free space.
#
# Why the bind mount: the HDD is mounted under /home/hbarn, and /home/hbarn is
# 0700, so the unprivileged `nixbld*` build users cannot traverse into it to
# reach the build dir (=> "Permission denied"). We bind the scratch dir to a
# top-level, world-traversable path (/nix-build) and point build-dir there.
#
# Toggle: flip `useHddBuildDir` and rebuild. The HDD is slower than the nvme,
# so builds may do disk I/O a bit slower, but CPU is normally the bottleneck.

let
  useHddBuildDir = true;
  hddDir = "/home/hbarn/mnt/hdd-sea-sata/nix-build";
  buildDir = "/nix-build";
in
lib.mkIf useHddBuildDir {
  # build-dir requires Nix >= 2.25 (this host runs 2.34).
  nix.settings.build-dir = buildDir;

  # Backing dir on the HDD (root-owned; the daemon builds as root/nixbld).
  systemd.tmpfiles.rules = [
    "d ${hddDir} 0755 root root -"
  ];

  # Expose it at a top-level path the nixbld users can actually traverse into.
  fileSystems.${buildDir} = {
    device = hddDir;
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/home/hbarn/mnt/hdd-sea-sata" ];
  };
}
