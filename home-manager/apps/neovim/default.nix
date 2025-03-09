{ config, pkgs, inputs, ... }: {
  programs.neovim = {
    enable = true;
    extraConfig = (builtins.readFile ./init.vim);
    viAlias = true;
    vimAlias = true;
  };
}
