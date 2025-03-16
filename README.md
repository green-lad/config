# About
This is my nixos configuration.
To list a few, it uses:
- [home-manager](https://github.com/nix-community/home-manager)
- firefox-addons
- [disko](https://github.com/nix-community/disko)
- [sops-nix](https://github.com/Mic92/sops-nix)

In [commands.md](./commands.md) is a list of usefule commands.

# Installation
- enable root login via ssh (/etc/sshd/sshd_config: PermitRootLogin yes)
- start sshd
- change hostname to x230
- deploy system:
> sudo nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake 'github:green-lad/config?ref=nixos#x230' --target-host root@x230
- (sops-nix won't work, you need to create your own secrets)

# TODO
- Use librewolf instead of firefox (didn't switch yet because bookmarks were not working immediately)
- Reset root system (impermanence)
- Get realtime kernel and linuxcnc working
- Have another separate host (desktop)
