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
    ./apps/rnote
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
      libreoffice

      blender
      cura-appimage
      delta
      dmenu
      feh
      ffmpeg_6
      graphviz
      htop
      jq
      killall
      lazygit
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

  # src: https://github.com/gepbird/dotfiles/blob/82902d8e5681c42411ed6125f8e9a9322ac3c6c1/modules/gtk-qt.nix#L10 (there the colortheme also gets set, but lets use the default)
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-error-bell = false;
    };
    gtk4.extraConfig = { gtk-error-bell = false; };
  };
}
