{ config, pkgs, inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    initContent = ''
      if command -v nix-your-shell > /dev/null; then
        nix-your-shell zsh | source /dev/stdin
      fi

      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      cd() {
        builtin cd "$@" && ls --color=auto 
      }
    '';

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "kardan";
            # "random"
            # "bureau" \
            # "eastwood" \
            # "fishy" \
            # "kardan" \
            # "kolo" \
            # "simple" \
            # "terminalparty_edited" \
            # "wezm" )
    };
  };
}
