# NixOS Flake

### Structure:

**Hosts:** Contains system level configurations organizes (mostly) into logical modules. (goal: potentially have multiple hosts for different platform ie.: desktop, laptop, rpi, ...)

**Home:** Contains user configuration matching the users defined in `hosts/<host>/users.nix`. Defining per user Home Manager config with separate user-space modules (DEs, shells, ...) and apps (packages, per-package customizations).

### Attention

The flake follows the **Unstable channel**!

### Installation

On fresh install: clone repo onto machine, cd into the dir and run the following:

```bash
# in /etc/nixos dir
sudo nixos-rebuild switch --flake .
```

### Server

The `server` target is an x86_64 NixOS host with one normal user (`hbarn`),
key-only SSH, and a single-node k3s server. It does not import Home Manager or
the desktop's package overlays.

Before deploying:

1. Set `sshPublicKey` in `hosts/server/configuration.nix` to the complete SSH public key string (for example, `ssh-ed25519 AAAA... admin@laptop`). An empty key intentionally blocks deployment. Never put a private key here.
2. On the target server, replace `hosts/server/hardware-configuration.nix` using `nixos-generate-config --show-hardware-config`. From an installer, mount the target filesystems first and pass `--root /mnt`. The committed file is only a placeholder, with no disk or boot configuration.
3. Configure the target's boot loader in `hosts/server/configuration.nix` (for example, systemd-boot for UEFI, or GRUB with the correct BIOS disk).
4. Include the new files in Git's index when using this Git-backed flake.

For an existing NixOS installation, deploy from the repository with:

```bash
sudo nixos-rebuild switch --flake .#server
```

From an installer, use `sudo nixos-install --flake .#server` instead.
Connect with `ssh hbarn@<server-address>`. The wheel user has passwordless sudo
because no account password is provisioned; protect the corresponding SSH
private key accordingly. Root SSH and password-based SSH logins are disabled.

k3s runs with its default single-node datastore. Use `sudo k3s kubectl get nodes`
to check it and `/etc/rancher/k3s/k3s.yaml` for the root-readable admin kubeconfig.
Only SSH is opened in the firewall; remote Kubernetes API access, workloads,
and additional cluster nodes need deliberate firewall configuration later.

#### Memory And Swap

The server uses 25% zram at priority 100, with no disk-backed swap configured.
This provides compressed swap for host services and occasional system updates
without reserving disk space for a swapfile.

k3s permits host swap through `fail-swap-on=false`, while retaining Kubernetes'
default `NoSwap` policy for pods. Host services can use zram, but pods cannot.
The kubelet flag is needed even with only zram enabled. Zram is emergency
headroom, not additional schedulable RAM. Set realistic pod memory requests and
limits in the Flux manifests; pods can still be OOM-killed at their memory
limits or evicted under node memory pressure.

After deploying, check `swapon --show`, `free -h`, and
`sudo k3s kubectl describe node` to verify swap and node memory health.
