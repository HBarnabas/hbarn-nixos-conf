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
The firewall also permits the configured Kubernetes and workload ports; review
`hosts/server/modules/network.nix` before exposing the server to other networks.

#### Samba Storage

The ext4 filesystem with UUID `1a97377c-cad8-4ab8-808f-d5b044993866`
is mounted at `/mnt/hdd-smb` and shared as `hdd`. Confirm the UUID with
`lsblk -f` on the server before deploying; this configuration does not format
the disk. The server can boot without the disk, but Samba will not start until
the filesystem is mounted. Once the disk is available, start it with
`sudo systemctl start samba-smbd`.

The share allows unauthenticated read/write access from `192.168.0.0/24` on
`enp6s0`, using TCP port 445. Anyone on that network can modify or delete its
contents; this is not suitable for untrusted networks. It is not exposed on
Tailscale. Connect directly to `smb://<server-lan-ip>/hdd` (Windows:
`\\<server-lan-ip>\hdd`); network discovery is not configured. Some clients
disable insecure guest access by default and require an explicit client-side
setting to connect.

At service startup the disk root is owned by the dedicated `smbguest` account
and set to mode 0755. Existing files are not changed recursively and must
already be accessible to that account if they are to be read or modified.
Check the mount and service with `findmnt /mnt/hdd-smb` and
`systemctl status samba-smbd`.

DHCP waits for an IPv4 address before marking the network online, so Samba
does not start with only IPv6 listeners. After rebuilding, run
`sudo systemctl restart samba-smbd` to bind the current LAN address.
Verify with `sudo ss -lntp 'sport = :445'`: the server's `192.168.0.x:445`
address must appear. On macOS, use Finder's **Go > Connect to Server**, enter
`smb://<server-lan-ip>/hdd`, and choose **Guest** when prompted.

Samba currently logs to the system journal with temporary diagnostic detail
for troubleshooting guest writes. After reproducing a failed write, inspect
`sudo journalctl -u samba-smbd --since '2 minutes ago' --no-pager`.
Once resolved, set `services.samba.settings.global."log level"` back to `"1"`
in `hosts/server/modules/network.nix` and rebuild.

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
