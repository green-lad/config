{ config, pkgs, inputs, ... }: {
  programs.helix = {
    extraPackages = with pkgs; [
      lazygit
    ];
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;
    languages = {
      language = [
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            # {
            #   name = "rust-analyzer";
            #   except-features = [ "diagnostics" "inlay-hints" "completion" ];
            # }
          ];
        }
      ];
      language-server = {
        rust-analyzer = {
          config = {
            checkOnSave = { enable = true; };
            diagnostics = { enable = false; };
          };
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

        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        lsp = {
          auto-signature-help = false;
        };

        whitespace = {
          render = "all";
        };

        indent-guides = {
          render = false;
          character = "|";
          skip-levels = 0;
        };
      };

      keys = {
        normal = {
          "\\" = ":pipe 'eval \"$(cat -)\"'";
          space.i = [
            ":vnew"
            ":config-open"
            ":sh rm %{buffer_name}"
          ];
          space.L = ":config-reload";
          space.e = [
            ":sh rm -f /tmp/unique-file-u41ae14"
            ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae14"
            ":insert-output echo \"\x1b[?1049h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file-u41ae14}"
            ":redraw"
          ];
          # TODO
          # space.E = [
          # ];
          C-space = "completion";
          C-m = "signature_help";
          C-g = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
          H = [
            "jump_backward"
            "align_view_center"
          ];
          L = [
            "jump_forward"
            "align_view_center"
          ];
          X = "extend_line_above";
          W = "@miw";
          C-h = "jump_view_left";
          C-l = "jump_view_right";
          C-k = "jump_view_up";
          C-j = "jump_view_down";
          G = {
            s = "extend_to_first_nonwhitespace";
            h = "extend_to_line_start";
            l = "extend_to_line_end";
          };
          space = {
            space = "last_picker";
            q = ":buffer-close";
            Q = ":buffer-close-others";
            t = {
              i = ":toggle-option lsp.display-inlay-hints";
              w = ":toggle-option soft-wrap.enable";
              x = ":toggle whitespace.render all none";
              n = ":toggle-option indent-guides.render";
              p = ":toggle-option lsp.display-progress-messages";
              # d = ":toggle enable-diagnostics";
            };
            l = {
              r = ":lsp-restart";
              s = ":lsp-stop";
              w = ":lsp-workspace-command";
            };
          };
        };
        insert = {
          C-m = "signature_help";
          C-space = "completion";
        };
        select = {
          X = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
        };
      };
    };
  };
}
