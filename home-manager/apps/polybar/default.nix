{ pkgs, hostname, user, ... }:
let
  local_flake = ''$"path:($env.HOME)/config#${hostname}"'';
  dependency_path = with pkgs;
    pkgs.lib.makeBinPath [
      "/run/wrappers"
      "/run/current-system/sw"
      "/etc/profiles/per-user/${user}"
      (writeScriptBin "control_wlan_fritzbox"
        (builtins.readFile ../../scripts/control_wlan_fritzbox.sh))
      (writeScriptBin "get_mail_count"
        (builtins.readFile ../../scripts/get_mail_count.sh))
      (writeScriptBin "get_most_urgent_task"
        (builtins.readFile ../../scripts/get_most_urgent_task.sh))
      "${inotify-tools}"
      (writeScriptBin "manage_display_sleep_enabled"
        (builtins.readFile ../../scripts/manage_display_sleep_enabled.sh))
      (writeScriptBin "restart_polybar"
        (builtins.readFile ../../scripts/restart_polybar.sh))
    ];
in {
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };

    script = "PATH=${dependency_path} restart_polybar";
    config = {
      "colors" = {
        background = "#1e1e20";
        text = "#ffffff";
        highlight = "#e06c75";
      };

      "bar/top" = {
        separator = "%{F#666666}|%{F-}";
        monitor = "\${env:MONITOR:}";
        width = "100%";
        height = 27;
        radius = 0;
        fixed-center = "true";
        top = "true";
        background = "\${colors.background}";
        foreground = "\${colors.text}";
        line-size = 3;
        border-size = 0;
        padding-left = 0;
        padding-right = 0;
        module-margin-left = 0;
        module-margin-right = 0;
        font-0 =
          "SauceCodePro Nerd Font Propo,SauceCodePro NFP:style=Regular:pixelsize=10;0";
        font-1 =
          "SauceCodePro Nerd Font Propo,SauceCodePro NFP:style=Regular:pixelsize=17;3";
        modules-left = "i3";
        modules-center = "date";
        modules-right =
          "eth wlan taskwarrior pulseaudio flameshot mail display_sleep_management battery restart powermenu";
        wm-restack = "i3";
        override-redirect = "false";
        enable-ipc = "true";
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapater = "AC";
      };

      "module/i3" = {
        type = "internal/i3";
        format = "<label-state> <label-mode>";
        index-sort = "true";
        wrapping-scroll = "false";
        label-focused = " %index% ";
        label-focused-foreground = "\${colors.highlight}";
        label-unfocused = " %index% ";
      };

      "module/wlan" = {
        type = "internal/network";
        interface = "wlan0";
        interval = 60;

        format-connected =
          "%{A1:control_wlan_fritzbox --off:}<ramp-signal><label-connected>%{A}";
        label-connected = "%essid%";
        format-disconnected = "%{A1:control_wlan_fritzbox --on:}󰖪 %{A}";
        ramp-signal-0 = "󰤯 ";
        ramp-signal-1 = "󰤟 ";
        ramp-signal-2 = "󰤢 ";
        ramp-signal-3 = "󰤥 ";
        ramp-signal-4 = "󰤨 ";
      };

      "module/eth" = {
        type = "internal/network";
        interface = "eno1";
        interval = 60;
        format-connected-prefix = " ";
        label-connected = "%local_ip%";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date-alt = " %Y-%m-%d";
        time = "%H:%M";
        time-alt = "%H:%M:%S";
        label = " %date% %time%";
      };

      "module/restart" = {
        type = "custom/menu";
        expand-right = "false";
        format-spacing = 1;
        label-open = "  󰜉  ";
        label-close = "  󰜺  ";
        menu-0-0 = "polybar";
        menu-0-0-exec = "systemctl --user restart polybar";
        menu-0-1 = "i3";
        menu-0-1-exec = "i3-msg restart";
        menu-0-2 = "home-manager";
        menu-0-2-exec =
          "wezterm start -- nu -c 'try { home-manager switch --flake ${local_flake} } catch { |err| $err.msg; input }' ";
        menu-0-3 = "nixos";
        menu-0-3-exec =
          "wezterm start -- nu -c 'try { sudo nixos-rebuild switch --flake ${local_flake} } catch { |err| $err.msg; input }' ";
      };

      "module/powermenu" = {
        type = "custom/menu";
        expand-right = "false";
        format-spacing = 1;
        label-open = "  󰐥  ";
        label-close = "  󰜺  ";
        menu-0-0 = "log_off";
        menu-0-0-exec = "#powermenu.open.1";
        menu-0-1 = "reboot";
        menu-0-1-exec = "#powermenu.open.2";
        menu-0-2 = "power_off";
        menu-0-2-exec = "#powermenu.open.3";
        menu-1-0 = "log_off";
        menu-1-0-exec = "i3 exit logout";
        menu-2-0 = "reboot";
        menu-2-0-exec = "reboot";
        menu-3-0 = "power_off";
        menu-3-0-exec = "poweroff";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = "true";
        interval = 5;
        reverse-scroll = "false";
        ramp-volume-0 = "󰕿";
        ramp-volume-1 = "󰖀";
        ramp-volume-2 = "󰕾";
        format-volume = "<ramp-volume> <label-volume>";
        label-muted = "󰝟";
        label-muted-padding = 2;
        format-muted = "<label-muted>";
        click-right = "wezterm -e mocp";
      };

      "module/flameshot" = {
        type = "custom/text";
        click-left = "flameshot gui";
        format = " 󰹑 ";
      };

      "module/display_sleep_management" = {
        type = "custom/script";
        exec = "manage_display_sleep_enabled";
        tail = true;
        click-left = "manage_display_sleep_enabled --toggle";
      };

      "module/mail" = {
        type = "custom/script";
        exec = "get_mail_count";
        tail = true;
        click-left = "wezterm -e neomutt";
        click-middle = "mbsync -a";
        click-right = "mbsync -a";
      };

      "module/taskwarrior" = {
        interval = 30;
        type = "custom/script";
        exec = "get_most_urgent_task";
        format = "<label>";
        click-left = ''task "$((`cat /tmp/tw_polybar_id`))" done'';
      };

      "settings" = {
        screenchange-reload = "true";
        format-padding = 1;
      };

      "global/wm" = {
        margin-top = 0;
        margin-bottom = 0;
      };
    };
  };
  systemd.user.services.polybar = {
    # NOTE: setting Service.Environment instead of wrapping polybar in its dependencies does not work
    #       because it gets "overwritten" (two entries, last one counts) by the home-manager polybar module
    Unit.After = [ "graphical-session-i3.target" ];
    Install.WantedBy = pkgs.lib.mkForce [ "graphical-session-i3.target" ];
  };
}
