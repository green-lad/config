{ config, pkgs, inputs, ... }: {
  services.polybar = {
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport  = true;
    };
    enable = true;
    extraConfig = (builtins.readFile ./config);
    script = "pkill polybar; polybar";
  };
}
