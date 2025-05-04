{ config, pkgs, inputs, ... }: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "-g"
      "!.git"
      "-g"
      "!debug"
      "--hyperlink-format"
      "kitty"
      "--no-heading"
    ];
  };
}
