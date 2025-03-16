{ config, pkgs, inputs, ... }: {
  xsession = {
    enable = true;
    initExtra = "xset r rate 200 50";
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      # define everything in config file for now
      config = {
        bars = [];
        modes = {};
        keybindings = {};
      };
      extraConfig = (builtins.readFile ./config);
    };
  };
}
