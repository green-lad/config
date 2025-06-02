{ lib, ... }:
let
  ls-command = "^ls --classify --color=always";
  dir-changes = builtins.concatStringsSep "\n" (map (count: ''
    def --env ${lib.concatStrings (lib.replicate count "o")} [] {
      cd ${builtins.concatStringsSep "/" (lib.replicate count "..")}
      ${ls-command}
    }
  '') (lib.range 1 5));
  # the preview is complicated because:
  # - preview value has to be a string -> --preview=""
  # - {} gets replaced by fzf with sh escapes (' -> '\'')
  # - but we are in nushell: wrap it in raw string with unlikely (4 consecutive # needed) match
  # - and then replace '\'' with '
  # - for nix escape double quotes and backslash
  # in short: build command inside nix string variable to replace sh escapes with nushell raw string
  # echo "##'" -> 'echo "##'\''"      ->     r####'echo "##'\''"'#### -> r####'echo "##'"'#### -> echo "##'" (ingoring nix context here)
  #    fzf sh replacement   review context for nushell            str replace        raw string evaluation
  fzf-event = [{
    send = "ExecuteHostCommand";
    cmd = let
      marker_with_change_escape_command =
        "r####{}#### | str replace -a r#''\\'''# r#'''#";
      preview = "${marker_with_change_escape_command} | nu-highlight";
      bind =
        "ctrl-y:execute-silent(${marker_with_change_escape_command} | xsel -b)+abort";
    in ''
      let choice = (
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
            --preview="${preview}"
            --preview-window='wrap'
            --bind="${bind}"
          | decode utf-8
          | str trim
      );
      if $choice != "" { commandline edit --replace $choice }
    '';
  }];
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
          mode = [ "emacs" "vi_normal" "vi_insert" ];
        }
        {
          name = "fuzzy_history_normal";
          modifier = "none";
          keycode = "char_/";
          mode = [ "vi_normal" ];
          event = fzf-event;
        }
        {
          name = "fuzzy_history";
          modifier = "control";
          keycode = "char_r";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf-event;
        }
      ];
    };

    extraConfig = ''
      ${dir-changes}
    '';
  };
}
