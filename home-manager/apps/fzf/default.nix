{ config, pkgs, inputs, ... }: {
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--bind ctrl-j:down,ctrl-k:up"
    ];
  };
}
