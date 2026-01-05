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
