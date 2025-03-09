{ config, pkgs, inputs, ... }: {
  programs.git = {
    enable = true;
    userName = "Markus Schoetz";
    userEmail = "markus.schoetz@fau.de";
  };
}
