{ pkgs, inputs, user, system, ... }: {
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
    ./apps/moc
    ./apps/neomutt
    ./apps/nushell
    ./apps/papis
    ./apps/pipewire_noise_cancelling
    ./apps/polybar
    ./apps/ripgrep
    ./apps/rnote
    ./apps/ssh
    ./apps/st
    ./apps/taskwarrior
    ./apps/wezterm
    ./apps/xdg
    ./apps/yazi
  ];

  # nixpkgs.overlays = [ inputs.additional-fonts.overlays.default ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      inputs.additional-fonts.packages.${system}.astetica
      inputs.additional-fonts.packages.${system}.leafery
      blender
      brightnessctl
      cura-appimage
      delta
      dmenu
      feh
      ffmpeg_6
      gnumake
      gimp
      graphviz
      htop
      jq
      killall
      lazygit
      libreoffice
      lightburn
      # moc
      mplayer
      obs-cmd
      obs-studio
      openscad
      pkg-config
      pulseaudio
      pulsemixer
      python3
      rustup
      songrec
      unzip
      xsel
      yt-dlp
      zathura
    ];
  };

  fonts.fontconfig.enable = true;

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
