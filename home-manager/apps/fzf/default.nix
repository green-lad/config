{ ... }: {
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--bind ctrl-j:down,ctrl-k:up"
      "--bind 'ctrl-/:change-preview-window(hidden|)'"
      "--bind 'ctrl-space:change-preview-window(top,99%|)'"
      "--no-mouse"
    ];
  };
}
