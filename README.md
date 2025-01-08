# NixOS config files

Separated into (for me) logical chunks and imported in `configuration.nix`, the config contains the following:
- sway wm with greetd login
- user homes and flakes enabled
- not-flaked packages separated to easier access
- audio config and related packages

Lutris is in its own file, so it's easily ignored when not needed (remove import from `configuration.nix`).

### Installation

On fresh install: clone repo onto machine, move files into `/etc/nixos` dir and run the following:

```bash
# in /etc/nixos dir
sudo nixos-rebuild switch --flake .#nixos
```

