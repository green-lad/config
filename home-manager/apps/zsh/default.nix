{ config, pkgs, inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    # TODO: history shortcuts don't work
    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      cd() {
        builtin cd "$@" && ls --color=auto 
      }
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
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
