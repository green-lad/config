# About
This is my nixos configuration.
It uses home-manager, firefox-addons, disko and more.

# Installation
- enable root login via ssh (/etc/sshd/sshd_config: PermitRootLogin yes)
- start sshd
- change hostname to x230
- deploy system:
> sudo nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake 'github:green-lad/config?ref=nixos#x230' --target-host root@x230

# TODO
- Use librewolf instead of firefox (didn't switch yet because bookmarks were not working immediately)
- Reset root system (impermanence)
- Use sops-nix
- Get realtime kernel and linuxcnc working
- Have another separate host (desktop)
