{ pkgs, inputs, lib, user, hostname, system, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix

    ./apps/firefox
    ./apps/git
    ./apps/i3
    ./apps/kitty
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
      yazi
      gnumake

      texliveFull
      texlivePackages.latexmk
    ];

    file = {
      # ".config/nvim/init.vim" = {
      #   source = ./apps/neovim/init.vim;
      # };
    };
  };
}
