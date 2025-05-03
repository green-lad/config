{ pkgs, inputs, lib, user, hostname, system, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix

    ./apps/firefox
    ./apps/git
    ./apps/i3
    ./apps/kitty
    ./apps/neomutt
    ./apps/polybar
    ./apps/ssh
    ./apps/xdg
    ./apps/zsh

    ./services/pipewire
  ];
  
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      inputs.nixvim.packages."${system}".default
      taskwarrior3
      dmenu
      (st.overrideAttrs (oldAttrs: rec {
        patches = [
          ./st.set_font.diff
        ];
      }))
      flameshot
      fzf
      openscad
      lightburn
      blender
      feh
      zathura
      gnumake
      urlscan

      texliveFull
      texlivePackages.latexmk

      zenity
      gnused
      xdg-desktop-portal-gtk
      # xdg-desktop-portal-gnome
      xdg-desktop-portal-termfilechooser
      yazi
    ];

    file = {
      # ".config/nvim/init.vim" = {
      #   source = ./apps/neovim/init.vim;
      # };
    };
  };
}
