{ ... }: {
  services.lorri.enable = true;
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
  };
  
  programs.nix-your-shell = {
    enable = true;
    enableNushellIntegration = true;
  };

  # config info: config nu --doc | nu-highlight | less -R
  programs.nushell = let
    # TODO: fix fzf preview for nested nushell (eg "nix-shell -p git" -> "nu")

    # the preview is complicated because:
    # - preview value has to be a string -> --preview=""
    # - {} gets replaced by fzf with sh escapes (' -> '\'')
    # - but we are in nushell: wrap it in raw string with unlikely (4 consecutive # needed) match
    # - and then replace '\'' with '
    # - for nix escape double quotes and backslash
    # in short: build command inside nix string variable to replace sh escapes with nushell raw string
    # echo "##'" -> 'echo "##'\''"      ->     r####'echo "##'\''"'#### -> r####'echo "##'"'#### -> echo "##'" (ingoring nix context here)
    #    fzf sh replacement   review context for nushell            str replace        raw string evaluation
    change_escape_command = cmd:
      "r####${cmd}#### | str replace -a r#''\\\\'''# r#'''#";
    fzf_search_history = [{
      send = "ExecuteHostCommand";
      cmd = let
        preview = "${change_escape_command "{}"} | nu-highlight";
        bind = "ctrl-y:execute-silent(${
            change_escape_command "{}"
          } | xsel -b)+abort";
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
    fzf_command_picker = [{
      send = "ExecuteHostCommand";
      cmd = let preview = "${change_escape_command "{3}"}";
      in ''
        let choice = (
          let c = char --unicode 7F;
          open ~/.nu_help.json
          | to csv -n -s $c
          | str join (char -i 0)
          | fzf
            --scheme history
            --tiebreak=begin
            --layout reverse
            --read0
            --delimiter $c
            --with-nth '{1} -- {2}'
            --accept-nth '{1}'
            --preview="${preview}"
            --preview-window='wrap'
            --no-multi-line
            --height 40%
        );
        if $choice != "" { commandline edit --insert $choice }
      '';
    }];
  in {
    enable = true;
    settings = {
      history = {
        sync_on_enter = false;
      };
      show_banner = false;
      edit_mode = "vi";

      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };

      keybindings = [
        {
          name = "reload_config";
          modifier = "control";
          keycode = "char_d";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''$env.PWD | xsel -b'';
          };
        }
        {
          name = "reload_config";
          modifier = "control";
          keycode = "char_e";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''commandline | xsel -b'';
          };
        }
        {
          name = "reload_config";
          modifier = "none";
          keycode = "f5";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = {
            send = "executehostcommand";
            cmd = ''$"source '($nu.env-path)'; source '($nu.config-path)'"'';
          };
        }
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
          event = fzf_search_history;
        }
        {
          name = "fuzzy_history";
          modifier = "control";
          keycode = "char_r";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_search_history;
        }
        {
          name = "fuzzy_history";
          modifier = "control";
          keycode = "char_h";
          mode = [ "emacs" "vi_normal" "vi_insert" ];
          event = fzf_command_picker;
        }
      ];
    };

    extraConfig = let preview = "${change_escape_command "'{1}\\n---\\n{2}'"}";
    in ''
      use std/dirs
      if ("~/.nu_help.json" | path type) != "file" {
        (
          help commands
          | select name description
          | insert help {|r| help $"($r.name)"}
          | save "~/.nu_help.json"
        )
      }

      def rd [name: string, n_remote = 100: int] {
        mut local = [];
        if (which "cargo" | length) > 0 {
          let metadata = ( 
            cargo metadata --format-version 1
            | from json
          )
          let doc_path = $"($metadata | get target_directory)/doc"
          $local = (
            $metadata
            | get packages
            | select name description
            | where {|r| $r.name =~ $"($name)" or not ($r.description | is-empty) and $r.description =~ $"($name)"}
            | insert documentation {|r| $"file://($doc_path)/($r.name | str replace -a '-' '_')/index.html"}
            | insert local "true"
          )
        }

        let remote =  (
          http get $"https://crates.io/api/v1/crates?q='($name)'&per_page=($n_remote)"
          | get crates
          | select name description
          | insert documentation {|r| $"https://docs.rs/($r.name)"}
          | insert local "false"
        )

        let choice = (
          $local
          | append $remote
          | to csv -n -s '#'
          | str join (char -i 0)
          | str replace -a '"' ""
          | fzf
            -m
            --scheme history
            --layout reverse
            --read0
            --delimiter '#'
            --with-nth '{1} -{4}- {2}'
            --accept-nth '{3}'
            --preview="${preview}"
            --preview-window='wrap'
            --no-multi-line
            --height 40%
          | lines
          | str join " "
        );
        if $choice != "" { sh -c $"librewolf ($choice) &"}
      }
    '';
  };
}
