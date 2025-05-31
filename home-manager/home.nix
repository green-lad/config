{ pkgs, inputs, lib, user, hostname, system, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
    inputs.nixvim.homeManagerModules.nixvim

    ./apps/clipmenu
    ./apps/librewolf
    ./apps/fzf
    ./apps/git
    ./apps/helix
    ./apps/i3
    ./apps/kitty
    ./apps/neomutt
    ./apps/neovim
    ./apps/nushell
    ./apps/papis
    ./apps/pipewire_noise_cancelling
    ./apps/polybar
    ./apps/ripgrep
    ./apps/ssh
    ./apps/wezterm
    ./apps/xdg
    ./apps/zsh
  ];
  
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      # inputs.nixvim.packages."${system}".default
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
      vimPlugins.kitty-scrollback-nvim
      # for polybar custom/scripts which wait for events
      inotify-tools


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
