{ config, pkgs, ... }: {
  home.sessionVariables = {
    "GTK_USE_PORTAL" = 1;
  };

  # TODO: building a new config does not restart xdg-desktop-portal or xdg-desktop-portal-termfilechooser
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      common = {
        default = "termfilechooser";
      };
    };
  };

  # src: https://discourse.nixos.org/t/how-to-install-xdg-desktop-portal-termfilechooser/62819/12
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = let
      launcherDeps = pkgs.buildEnv {
        name = "yazi-launcher-dependencies";
        paths = with pkgs; [
          coreutils
          yazi
          gnused
          bashInteractive
        ];
      };
    in ''
      [filechooser]
      env=PATH='${launcherDeps}/bin'
      env=TERMCMD='${pkgs.kitty}/bin/kitty'
      cmd='${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh'
      default_dir=$HOME
      open_mode=suggested
    '';
}
