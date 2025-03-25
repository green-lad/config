{ config, pkgs, inputs, user, hostname, ... }: {
  imports = [
    ../host_hardware/${hostname}
  ];
  
  environment = {
    # Remove unecessary preinstalled packages
    defaultPackages = [ ];
    # packages that have no home-manager configs
    systemPackages = with pkgs; [
      age
      sops
      htop
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

    openssh = {
      enable = true;
      #settings.PermitRootLogin = "prohibit-password";
      settings.PermitRootLogin = "yes";
    };

    libinput.enable = true;

    getty.autologinUser = user;

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
        user = user;
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
    settings.allowed-users = [ user ];
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
    hostName = hostname;
    networkmanager.enable = true;
    # needed for zfs
    hostId = "8425e349";
    wireless.iwd.enable = true;
    nftables.ruleset = ''
      # Check out https://wiki.nftables.org/ for better documentation.
      # Table for both IPv4 and IPv6.
      table inet filter {
        # Block all incoming connections traffic except SSH and "ping".
        chain input {
          type filter hook input priority 0;
      
          # accept any localhost traffic
          iifname lo accept
      
          # accept traffic originated from us
          ct state {established, related} accept
      
          # ICMP
          # routers may also want: mld-listener-query, nd-router-solicit
          ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept
      
          # allow "ping"
          ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          ip protocol icmp icmp type echo-request accept
      
          tcp dport {ssh,http,https} accept
      
          # count and drop any other traffic
          counter drop
        }
      
        # Allow all outgoing connections.
        chain output {
          type filter hook output priority 0;
          accept
        }
      
        chain forward {
          type filter hook forward priority 0;
          accept
        }
      }
    '';
    # firewall = {
    #   enable = true;
    #   allowedTCPPorts = [ 443 80 ];
    #   allowedUDPPorts = [ 443 80 44857 ];
    #   allowPing = false;
    # };
    interfaces.enp0s25 = {
      ipv4.addresses = [{
        address = "10.10.10.1";
        prefixLength = 24;
      }];
    };
  };

  # Ensure the uinput group exists
  users.groups.uinput = { };
  users.users = let
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAP46k4CU/BnDnnrXA4NZKUXm00Exc3yEyZ4J4dIFPIf markus.schoetz@fau.de" #x230
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINFEIGdKfvmy7cfhjnE6RAi2fw0qaUApBTRgTuLCI5Ji markus.schoetz@fau.de" #nux
    ];
  in {
    "${user}" = {
      shell = pkgs.zsh;
      isNormalUser = true;
      hashedPassword = "$6$igRbgm5cDL1ZG0Zc$tmrJZPcQtk7sul2Zumk7XidoVta8xE4sSZvPCCmRIbyDmw7b9bx5BG6XlXUfcOVVPh/wor.YirIZ3Sw5zB.tN0";
      home = "/home/${user}";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      packages = with pkgs; [
      ];
      openssh.authorizedKeys.keys = authorizedKeys;
    };
    root = {
      openssh.authorizedKeys.keys = authorizedKeys;
    };
  };

  # don't touch
  system.stateVersion = "24.11"; # Did you read the comment?

}

