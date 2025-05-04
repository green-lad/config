{ config, pkgs, inputs, ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "Brogrammer";

    font = {
      name = "SauceCodePro Nerd Font Propo:style=Regular";
      package = pkgs.nerd-fonts.sauce-code-pro;
    };

    keybindings = {
      "kitty_mod+g"         = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
      "kitty_mod+h"         = "kitty_scrollback_nvim";
    };

    settings = {
      enable_audio_bell = false;

      # for kitty-scrollback.nvim
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      shell_integration = "enabled";
      action_alias = "kitty_scrollback_nvim kitten" + " ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py";

      mouse_hide_wait = "-1.0";
      text_composition_strategy = "legacy";
    };
    
    extraConfig = ''
      mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
    '';
  };

  xdg.configFile."kitty/open-actions.conf".text = ''
    # Open any file with a fragment in EDITOR, fragments are generated
    # by the hyperlink_grep kitten and nothing else so far.
    protocol file
    fragment_matches [0-9]+
    action launch --type=overlay ''${EDITOR} +''${FRAGMENT} ''${FILE_PATH}

    # Open text files without fragments in the editor
    protocol file
    mime text/*
    action launch --type=overlay ''${EDITOR} ''${FILE_PATH}

    protocol file
    ext csv
    action launch --type=overlay ${pkgs.visidata}/bin/vd ''${FILE_PATH}

    # Open directories
    protocol file
    mime inode/directory
    action launch --type=os-window --cwd ''${FILE_PATH}

    # Open any image in the full kitty window by clicking on it
    protocol file
    mime image/*
    action launch --type=overlay kitty +kitten icat --hold ''${FILE_PATH}
  '';
}
