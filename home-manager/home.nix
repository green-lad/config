{ pkgs, inputs, user, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
    inputs.nixvim.homeManagerModules.nixvim

    # ./apps/blender
    ./apps/clipmenu
    ./apps/flameshot
    ./apps/fzf
    ./apps/git
    ./apps/helix
    ./apps/i3
    ./apps/librewolf
    ./apps/neomutt
    ./apps/nushell
    ./apps/papis
    ./apps/pipewire_noise_cancelling
    ./apps/polybar
    ./apps/ripgrep
    ./apps/ssh
    ./apps/taskwarrior
    ./apps/wezterm
    ./apps/xdg
    ./apps/yazi
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      blender
      cura-appimage
      delta
      dmenu
      feh
      ffmpeg_6
      htop
      killall
      lightburn
      moc
      openscad
      pulsemixer
      unzip
      xsel
      yt-dlp
      zathura
    ];
  };
}
