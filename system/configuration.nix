{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  environment = {
    # Remove unecessary preinstalled packages
    defaultPackages = [ ];
    # packages that have no home-manager configs
    systemPackages = with pkgs; [
      xsel
      neovim
      moc
      killall
      home-manager
    ];
    sessionVariables = {
    };
    variables = {
      NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
      NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
      XDG_DATA_HOME = "$HOME/.local/share";
      PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
      GTK_RC_FILES = "$HOME/.local/share/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "$HOME/.local/share/gtk-2.0/gtkrc";
      MOZ_ENABLE_WAYLAND = "1";
      ZK_NOTEBOOK_DIR = "$HOME/stuff/notes/";
      EDITOR = "nvim";
      DIRENV_LOG_FORMAT = "";
      ANKI_WAYLAND = "1";
      DISABLE_QT5_COMPAT = "0";
    };
  };

  boot = {
    kernelModules = [ "uinput" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.uinput.enable = true;

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  programs = {
    zsh.enable = true;
    # hyprland = {
    #   enable = true;
    #   xwayland.enable = true;
    # };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    openssh.enable = true;

    libinput.enable = true;

    getty.autologinUser = "markus";

    printing.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "de(us)";
        options = "eurosign:e,caps:swapescape";
      };
      desktopManager = {
        xterm.enable = false;
      };
      windowManager.i3 = {
        enable = true;
      };
      # displayManager = {
      #   startx.enable = true;
      # };
    };

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "markus";
      };
    };

    # only used for wayland
    # kanata = {
    #   enable = true;
    #   keyboards = {
    #     internalKeyboard = {
    #       devices = [
    #         # Replace the paths below with the appropriate device paths for your setup.
    #         # Use `ls /dev/input/by-path/` to find your keyboard devices.
    #         "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    #       ];
    #       extraDefCfg = "process-unmapped-keys yes";
    #       config = ''
    #         (defsrc
    #          caps tab d h j k l ; [ ' - e
    #         )
    #         (defvar
    #          tap-time 200
    #          hold-time 200
    #         )
    #         (defalias
    #          caps (tap-hold 200 200 esc lctl)
    #          tab (tap-hold $tap-time $hold-time tab (layer-toggle arrow))
    #          del del  ;; Alias for the true delete key action

    #          ;; umlaute
    #          Ae (unicode Ä)
    #          Ue (unicode Ü)
    #          Oe (unicode Ö)
    #          ae (unicode ä)
    #          ue (unicode ü)
    #          oe (unicode ö)
    #          _ae (fork @ae @Ae (lsft rsft))
    #          _ue (fork @ue @Ue (lsft rsft))
    #          _oe (fork @oe @Oe (lsft rsft))
    #          sz (unicode ß)
    #          eu (unicode €)
 
    #         )
    #         (deflayer base
    #          @caps @tab d h j k l ; [ ' - e
    #         )
    #         (deflayer arrow
    #          _ _ @del left down up right @oe @ue @ae @sz @eu
    #         )
    #       '';
    #     };
    #   };
    # };
  };

  # Install fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.sauce-code-pro
    ];

    fontconfig = {
      hinting.autohint = true;
      defaultFonts = {
       emoji = [ "OpenMoji Color" ];
      };
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "markus" ];
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  networking = {
    hostName = "x230";
    networkmanager.enable = true;
    # needed for zfs
    hostId = "8425e349";
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 443 80 ];
      allowedUDPPorts = [ 443 80 44857 ];
      allowPing = false;
    };
  };

  # Ensure the uinput group exists
  users.groups.uinput = { };
  users.users.markus = {
    shell = pkgs.zsh;
    isNormalUser = true;
    hashedPassword = "$6$igRbgm5cDL1ZG0Zc$tmrJZPcQtk7sul2Zumk7XidoVta8xE4sSZvPCCmRIbyDmw7b9bx5BG6XlXUfcOVVPh/wor.YirIZ3Sw5zB.tN0";
    home = "/home/markus";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuknMwnBgC9ZS/iAP+Uxs6uWQ6Q4YLxZb0XU6B+rEjQ8pNTO9Fry8OO0UQCuONmDk2e5UCZdRd072lThWFuEQ3OLv9Q5GXOBd7Yd2w6ov5orGTPLVDiHhT4Hhl8EBj/bZf4kP5fQeBmkWnN+7MLJQCCwLwdhyCMXDVCIYTkSispNVGTvUbZr0fdxy49Ey65XSGm2ib270o0mNgEnmcr81NnSxIxMNLnpoCJ8Sir4/TmNyrVBSm5Se2VYlCLiYgKj93flF3rR2QmuEHW1vURkOJKip+XhmmWbJ2J6eZqQrLCY9i8b8C9B/5xS+84Pz8EoqrNefRAzE6/xqcS9O+Ko2xqBo/V0jimfSpU1Mp9O8zgYIP9YXiuRLFFxLtKcJ+Qy6RoOukUcdILDVy9R8dCkv65l4125TbTXShXcQML3BL1L562FGIpQvCCA+8E29mLfvOZkfyHUGOcrB+Uw/58Qjq03BGiJ6hR4HhB3WGw3/aJL1NG1L8jcf+vvOFVf34X9DUYaQSJIT8B32PZEUwk/Hk3tLlhhdrLWOLek6RpIlcAT8Z3umOif0taMiRlilo2qHYDGjY9QSdo30ugqzUIDH20PxPyViR6/Af8WdGAThINMVVth4ltGSz7Hl3jbaVdhac+Y/ShGmHac6w8uAFz8C6zaCxCj59YvYtsz50LK0ukw== markus@n2"
    ];
  };

  # don't touch
  system.stateVersion = "24.11"; # Did you read the comment?

}

