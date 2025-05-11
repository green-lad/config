# About
This is my nixos configuration.
To list a few, it uses:
- [home-manager](https://github.com/nix-community/home-manager)
- firefox-addons
- [disko](https://github.com/nix-community/disko)
- [sops-nix](https://github.com/Mic92/sops-nix)

In [commands.md](./commands.md) is a list of usefule commands.

# Installation
- enable root login via ssh (/etc/ssh/sshd_config: PermitRootLogin yes)
- start sshd
- change hostname to desired name (<host>)
- deploy system: (add "--generate-hardware-config nixos-generate-config ./host_hardware/<host>/default.nix" to generate initial hardware config)
> sudo nix --experimental-features 'nix-command flakes' run github:nix-community/nixos-anywhere -- --flake 'github:green-lad/config?ref=nixos#<host>' --target-host root@<host>
- (sops-nix won't work, you need to create your own secrets)

# Program info
## Firefox
I use [shyfox](https://github.com/Naezr/ShyFox) but mashed into [userchrome.css](./home-manager/apps/firefox/userChrome.css) and [usercontent.css](./home-manager/apps/firefox/userContent.css) with slight changes.
To play around with it enable remote debugging in firefox and open it via ctrl+alt+shift+i.
In the future I might want to switch to librewolf (currently some stuff does not work with the current setting, like [bookmarks](https://www.reddit.com/r/NixOS/comments/1j0oky4/declaring_librewolf_bookmarks/)).

# TODO
- Use librewolf instead of firefox (didn't switch yet because bookmarks were not working immediately)
- Reset root system (impermanence)
- Get realtime kernel and linuxcnc working
- Work on the split between hosts
- Get nixos-anywhere working again (when running it, nixos-installer gets booted; disko stuff seems fine, maybe sops-nix is the problem) 
- Also configure firefox plugins like sideberry or violetmonkey to not have to configure them on first use
- Make a search engine for firefox which can query mutliple arguments (for example github search engine: searchTerm, language)
- Work on separation of concerns and reflection of dependencies (for example polybar using neomutt)
- Fix xdg-desktop-portal-termfilechooser.service and mbsync.service not starting on switch
- Fix termfilechooser sporadically not working (for example when using file input in firefox)
    A first look shows that after home-manager switch it seems to be working again, it seems like a (system) service is not running
- Make every path in every command output clickable (for example by making it a hyperlink: printf '\e]8;;%s\e\\%s\e]8;;\e\\\n' "file:///home/markus/config" "config")
- Change hardcoded runtimepath plugin values to dynamic nix store entry in home-manager/apps/neovim/default.nix
