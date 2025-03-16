{ pkgs, inputs, lib, user, hostname, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./sops.nix

    ./apps/firefox
    ./apps/git
    ./apps/i3
    ./sops.nix
    ./apps/polybar
    ./apps/ssh
    ./apps/zsh
  ];
  
  home = {
    username = user;
    homeDirectory = "/home/${user}";
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
