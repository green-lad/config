{ ... }: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "-g"
      "!.git"
      "-g"
      "!debug"
      "--hyperlink-format"
      "default"
      "--no-heading"
    ];
  };
}
