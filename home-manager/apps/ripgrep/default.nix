{ ... }: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "-g"
      "!.git"
      "-g"
      "!debug"
      "--hyperlink-format"
      # "file://{path}:{line}"
      # "default"
      "none"
      "--no-heading"
    ];
  };
}
