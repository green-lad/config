{ config, pkgs, inputs, ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "Brogrammer";

    font = {
      name = "SauceCodePro Nerd Font Propo:style=Regular";
      package = pkgs.nerd-fonts.sauce-code-pro;
    };

    keybindings = {
    };

    settings = {
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      text_composition_strategy = "legacy";
    };
  };
}
