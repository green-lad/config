{ pkgs, inputs, lib, user, hostname, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix

    ./apps/firefox
    ./apps/git
    ./apps/i3
    ./apps/polybar
    ./apps/ssh
    ./apps/xdg
    ./apps/zsh
  ];
  
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
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
  };
}
