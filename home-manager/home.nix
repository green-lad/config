{ pkgs, inputs, lib, ... }: {
  imports = [
    ./apps/git
    ./apps/firefox
    ./apps/zsh
    ./apps/i3
    ./apps/polybar
  ];

  home = {
    username = "markus";
    homeDirectory = "/home/markus";
    stateVersion = "24.11";
    packages = with pkgs; [
      python3
      (writeScriptBin "get_mail_count" (builtins.readFile ./scripts/get_mail_count.py))
      (writeScriptBin "get_most_urgent_task" (builtins.readFile ./scripts/get_most_urgent_task.sh))
      (writeScriptBin "restart_polybar" (builtins.readFile ./scripts/restart_polybar.sh))

      taskwarrior3
      dmenu
      (st.overrideAttrs (oldAttrs: rec {
        patches = [
          ./st.set_font.diff
        ];
      }))
      flameshot
      fzf
      openscad
      lightburn
      blender
    ];
  };
}
