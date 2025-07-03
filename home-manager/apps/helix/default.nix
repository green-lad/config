{ config, pkgs, inputs, ... }: {
  programs.helix = {
    extraPackages = with pkgs; [
      codebook
      helix-gpt
      jq
      lazygit
      nil
      nixfmt-rfc-style
      (python3.withPackages (p: (with p; [
        python-lsp-server
      ])))
      rust-analyzer
      rustfmt
      texlab
      typescript-language-server
    ];
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    languages = {
      language = [
        {
          name = "json";
          formatter.command = "${pkgs.jq}/bin/jq";
        }
        {
          name = "latex";
          language-servers = [ "texlab" "codebook" ];
        }
        {
          name = "markdown";
          language-servers = [ "codebook" ];
        }
        {
          name = "nix";
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }
        {
          name = "python";
          language-servers = [ "pylsp" "gpt" ];
        }
        {
          name = "rust";
          formatter = { command = "rustfmt"; };
          language-servers = [ "rust-analyzer" "codebook" "gpt" ];
        }
        {
          name = "text";

          # not sure why those are needed according to helix
          file-types = [ "text" "txt" ];
          scope = "source.text";

          indent = {
            tab-width = 4;
            unit = "    ";
          };
          language-servers = [ "codebook" ];
        }
      ];
      language-server = {
        rust-analyzer = {
          config = {
            checkOnSave = { enable = true; };
            diagnostics = { enable = true; };
          };
        };
        gpt = {
          command = "helix-gpt";
          args = [
            "--handler"
            "ollama"
            "--ollamaModel"
            "codellama"
            "--fetchTimeout"
            "300000"
            "--actionTimeout"
            "300000"
            "--completionTimeout"
            "300000"
            "--ollamaTimeout"
            "300000"
            "--triggerCharacters"
            ""
          ];
        };
        codebook = {
          command = "codebook-lsp";
          args = [ "serve" ];
        };
      };
    };
    settings = {
      theme = "iceberg-dark";

      editor = {
        auto-pairs = false;
        scrolloff = 0;
        line-number = "relative";
        bufferline = "always";
        end-of-line-diagnostics = "hint";
        auto-completion = false;
        path-completion = true;
        soft-wrap = {
          enable = true;
          max-wrap = 0;
        };
        shell = [ "nu" "--stdin" "-c" ];

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        file-picker = { hidden = false; };

        lsp = { auto-signature-help = false; };

        whitespace = { render = "all"; };

        indent-guides = {
          render = false;
          character = "|";
          skip-levels = 0;
        };

        statusline = {
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "total-line-numbers"
            "primary-selection-length"
            "file-encoding"
          ];
        };
      };

      keys = {
        normal = {
          "\\" = ":pipe 'nu -c $in'";
          "*" = [ "search_selection" "search_next" ];
          "A-*" = [ "search_selection_detect_word_boundaries" "search_next" ];
          C-space = "completion";
          C-p = "signature_help";
          C-q = [
            '':pipe-to save "%{buffer_name}.tmp.a"''
            ":clipboard-paste-after"
            '':pipe-to save "%{buffer_name}.tmp.b"''
            "undo"
            '':hs "%{buffer_name}.tmp"''
            ''
              :insert-output diff --tabsize=4 -y "%{buffer_name}.a" "%{buffer_name}.b" | str replace -ra "(<|>) " "''${1}" | str replace -a ' ' '·' ''
            ":write"
            '':sh rm "%{buffer_name}.a" "%{buffer_name}.b" "%{buffer_name}"''
            "goto_file_start"
          ];
          C-e = [
            '':pipe-to save "%{buffer_name}.tmp.a"''
            ":clipboard-paste-after"
            '':pipe-to save "%{buffer_name}.tmp.b"''
            "undo"
            '':hs "%{buffer_name}.tmp"''
            ''
              :insert-output diff "%{buffer_name}.a" "%{buffer_name}.b" | str replace -ra "(<|>) " "''${1}" | str replace -a ' ' '·' ''
            ":write"
            '':sh rm "%{buffer_name}.a" "%{buffer_name}.b" "%{buffer_name}"''
            "goto_file_start"
          ];
          C-g = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
          H = [ "jump_backward" "align_view_center" ];
          L = [ "jump_forward" "align_view_center" ];
          X = "extend_line_above";
          W = "@glGs";
          C-h = "jump_view_left";
          C-l = "jump_view_right";
          C-k = "jump_view_up";
          C-j = "jump_view_down";
          G = {
            s = "extend_to_first_nonwhitespace";
            h = "extend_to_line_start";
            l = "extend_to_line_end";
          };
          F5 = ":config-reload";
          space = {
            space = "last_picker";
            C-q = ":buffer-close!";
            q = ":buffer-close";
            Q = ":buffer-close-others";
            t = {
              i = ":toggle-option lsp.display-inlay-hints";
              w = ":toggle-option soft-wrap.enable";
              x = ":toggle whitespace.render all none";
              n = ":toggle-option indent-guides.render";
              p = ":toggle-option lsp.display-progress-messages";
            };
            l = {
              r = ":lsp-restart";
              s = ":lsp-stop";
              w = ":lsp-workspace-command";
            };
            u = ":sh rm %{buffer_name}";
            i = ":open ${config.xdg.configHome}";
            I = ":config-open";
            L = ":config-reload";
            e = [
              ":sh rm -f /tmp/unique-file-u41ae14"
              ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae14"
              '':insert-output echo "x1b[?1049h" > /dev/tty''
              ":open %sh{cat /tmp/unique-file-u41ae14}"
              ":redraw"
            ];
            E = [
              ":sh rm -f /tmp/unique-file-u41ae15"
              ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae15"
              '':insert-output echo "x1b[?1049h" > /dev/tty''
              ":cd %sh{cat /tmp/unique-file-u41ae14}"
            ];
            "|" = {
              s = ":pipe 'lines | sort | to text --no-newline'";
              u = ":pipe 'lines | uniq | to text --no-newline'";
              a = [
                "save_selection"
                "select_all"
                ":sh %{selection}"
                "jump_backward"
              ];
            };
          };
        };
        insert = {
          C-p = "signature_help";
          C-space = "completion";
        };
        select = { X = [ "extend_line_up" "extend_to_line_bounds" ]; };
      };
    };
  };
}
