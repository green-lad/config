{ config, pkgs, inputs, lib, ... }:
let
  ls-command = "^ls --classify --color=always";
  dir-changes = builtins.concatStringsSep "\n" (
    map (count: ''
      def --env ${lib.concatStrings (lib.replicate count "o")} [] {
        cd ${builtins.concatStringsSep "/" (lib.replicate count "..")}
        ${ls-command}
      }
    '') (lib.range 1 5)
  );
  fzf-event = [
    {
      send = "ExecuteHostCommand";
      cmd = ''commandline edit --insert (
        history
          | get command
          | reverse
          | uniq
          | str join (char -i 0)
          | fzf
            --scheme history
            --read0
            --layout reverse
            --height 40%
            --preview='echo {} | nu-highlight'
            --preview-window='wrap'
          | decode utf-8
          | str trim
      )'';
    }
  ];
in {
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";

      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };

      keybindings = [
        {
          name = "unfreeze";
          modifier = "control";
          keycode = "char_z";
          event = {
            send = "executehostcommand";
            cmd = "job unfreeze";
          };
          mode = [
            "emacs"
            "vi_normal"
            "vi_insert"
          ];
        }
        {
          name = "fuzzy_history_normal";
          modifier = "none";
          keycode = "char_/";
          mode = [
            "vi_normal"
          ];
          event = fzf-event;
        }
        {
          name = "fuzzy_history";
          modifier = "control";
          keycode = "char_r";
          mode = [
            "emacs"
            "vi_normal"
            "vi_insert"
          ];
          event = fzf-event;
        }
      ];
    };

    extraConfig = ''
      ${dir-changes}
    '';
  };
}
