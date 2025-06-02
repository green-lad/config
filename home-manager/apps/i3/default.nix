{ pkgs, ... }: {
  systemd.user.targets.graphical-session-i3 = {
    Unit = {
      Description = "i3 X session";
      BindsTo = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
  };
  xsession = {
    enable = true;
    initExtra = "xset r rate 200 50";
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      # define everything in config file for now
      config = {
        bars = [ ];
        modes = { };
        keybindings = { };
        startup = [{
          command =
            "${pkgs.systemd}/bin/systemctl --user start graphical-session-i3.target";
          notification = false;
        }];
      };
      extraConfig = (builtins.readFile ./config);
    };
  };
}
