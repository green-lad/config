{ config, pkgs, inputs, ... }: {
  services.clipmenu = {
    enable = true;
    launcher = "dmenu";
  };
}
