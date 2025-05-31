{ config, pkgs, inputs, ... }: {
  config.xdg.configFile = {
    "neomutt/mailcap" = {
      enable = true;
      text = ''
        text/*; xdg-open %s; needsterminal=false
        application/*; xdg-open %s; needsterminal=false
        image/*; xdg-open %s; needsterminal=false
      '';
    };
  };

  config.programs.abook = {
    enable = true;
  };

  config.programs.msmtp.enable = true;
  config.programs.mbsync.enable = true;

  config.services.mbsync = {
    enable = true;
    frequency = "*:0/2";
  };

  config.accounts.email.accounts.Personal = {
    address = "markus.schoetz@fau.de";
    realName = "Markus Schoetz";
    userName = "markus.schoetz@fau.de";
    passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.imap_password.path}";

    mbsync = {
      enable = true;
      create = "maildir";
      remove = "both";
      expunge = "both";
    };

    msmtp.enable = true;

    smtp = {
      host = "smtp-auth.fau.de";
      port = 587;
      tls.useStartTls = true;
    };

    imap = {
      host = "faumail.fau.de";
      port = 143;
      tls.useStartTls = true;
    };

    neomutt = {
      enable = true;
      sendMailCommand = "${pkgs.msmtp}/bin/msmtp -a Personal";
      extraMailboxes = [
        "Archive"
        "Drafts"
        "Sent"
        "Trash"
      ];

      # extraConfig = ''
      #   set pgp_default_key = "${pgpKey}"
      #   set pgp_sign_as = "${pgpKey}"
      # '';
    };

    signature = {
      showSignature = "append";
      text = ''
        Markus Schoetz
        https://green-lad.xyz
      '';
    };

    # gpgConfig.gpg = {
    #   encryptByDefault = true;
    #   signByDefault = true;
    # };

    primary = true;
    flavor = "plain";
    folders = {
      inbox = "INBOX";
      drafts = "Drafts";
      sent = "Sent";
      trash = "Trash";
    };
  };

  config.programs.neomutt = {
    # package = let
    #   dependency_path = with pkgs; "PATH=${pkgs.neomutt}/bin:/run/wrappers/bin:${lib.makeBinPath [
    #     abook
    #     isync
    #     coreutils-full
    #     urlscan
    #     msmtp
    #     abook
    #     xdg-utils
    #     zathura
    #     firefox
    #     neovim
    #   ]}";
    # in pkgs.stdenv.mkDerivation {
    #   pname = "neomutt_with_dependencies";
    #   version = "1.0";
    #
    #   # skip unpackPhase (no src)
    #   unpackPhase = "true";
    #
    #   buildInputs = [ pkgs.neomutt ];
    #
    #   nativeBuildInputs = [ pkgs.makeWrapper ];
    #
    #   # Define the install phase
    #   installPhase = ''
    #     mkdir -p $out/bin
    #     cp ${pkgs.neomutt}/bin/neomutt $out/bin/neomutt
    #     mkdir -p $out/share/doc/neomutt/vim-keys
    #     cp ${pkgs.neomutt}/share/doc/neomutt/vim-keys/vim-keys.rc $out/share/doc/neomutt/vim-keys
    #     wrapProgram $out/bin/neomutt \
    #       --set PATH "${dependency_path}:$PATH"
    #   '';
    # };

    enable = true;
    vimKeys = true;
    editor = "nvim";
    binds = [
      {
        action = "complete-query";
        key = "<Tab>";
        map = [ "editor" ];
      }
      {
        action = "group-reply";
        key = "R";
        map = [ "index" "pager" ];
      }
    ];
    macros = [
      {
        action = "<sidebar-prev><sidebar-open>";
        key = "[";
        map = [ "index" "pager" ];
      }
      {
        action = "<sidebar-next><sidebar-open>";
        key = "]";
        map = [ "index" "pager" ];
      }
      {
        action = "!systemctl --user start mbsync &^M";
        key = "<F5>";
        map = [ "index" ];
      }
      {
        action =
          "<change-folder>${config.accounts.email.accounts.Personal.maildir.absPath}/INBOX<enter>";
        key = "P";
        map = [ "index" ];
      }
      {
        action = "<save-message>+Archive<enter>";
        key = "A";
        map = [ "index" "pager" ];
      }
      {
        action = "<save-message>?<tab>";
        key = "s";
        map = [ "index" ];
      }
      {
        action = "<pipe-message>urlscan -dc<Enter>";
        key = "\\Cl";
        map = [ "index" "pager" ];
      }
      {
        action = "<pipe-entry>urlscan -dc<Enter>";
        key = "\\Cl";
        map = [ "attach" "compose" ];
      }
    ];

    sidebar = {
      enable = true;
      width = 40;
      format = "%B%?F? [%F]?%* %?N?%N/?%S";
      shortPath = false;
    };

    settings = {
      abort_key = "<Esc>";
      # alias_file = aliasfile;
      allow_ansi = "yes";
      beep = "no";
      beep_new = "no"; # bell on new mails
      confirmappend = "no"; # don't ask, just do!
      delete = "yes"; # don't ask, just do
      edit_headers = "yes"; # show headers when composing
      fast_reply = "yes"; # skip to compose when replying
      fcc_attach = "yes"; # save attachments with the body
      folder = "${config.home.homeDirectory}/Mail";
      forward_quote = "yes"; # include message in forwards
      include = "yes"; # include message in replies
      mail_check = "0"; # how often look for new mail
      mailcap_path = "${config.xdg.configHome}/neomutt/mailcap";
      mark_old = "no"; # read/new is good enough for me
      markers = "no"; # show '+' at start of wrapped lines
      move = "no"; # gmail does that
      pager_context = "3";
      pager_index_lines =
        "10"; # shows 10 lines of index when pager is active
      pager_stop = "yes";
      quit = "yes"; # don't ask, just do!!
      reply_to = "yes"; # reply to Reply to: field
      reverse_name = "yes"; # reply as whomever it was to
      sort = "threads";
      sort_aux = "reverse-last-date-received";
      sort_re = "yes";
      text_flowed = "yes";
      timeout = "0";
      tmpdir = "${config.xdg.configHome}/neomutt/tmp";
      wait_key = "no"; # don't ask "press key to continue"

      imap_check_subscribed = "yes";
      mail_check_stats = "yes";
    };

    extraConfig = ''
      # Use return to open message because I'm not a savage
      unbind index <return>
      bind index <return> display-message

      # Use N to toggle new
      unbind index N
      bind index N toggle-new

      lists .*@lists.sr.ht

      # Theme formats
      set date_format = "%d %h %H:%M";
      set status_chars = " 󰁦";
      set status_format = "[ %D ] %?r?[ 󰇰 %m ] ?%?n?[ 󰇮 %n ] ?%?d?[ 󰩹 %d ] ?%?t?[  %t ] ?%?F?[  %F ] ?%?p?[  %p ]?%|─";
      set crypt_chars = "󰈡 ";
      set flag_chars = "󰩹󰩺 󰇰󰇮 ";
      set to_chars = " ";
      set pager_format = "[ %n ] [ %T %s ]%* [ 󰸗 %{!%Y %a %d %b %H:%M} ] %?X?[ 󰁦 %X ]? [  %P ]%|─";
      # set pager_format = "[ %n ]

      # color index color0 default '~R'
      set query_command= "abook --mutt-query '%s'"
      macro index,pager  a "<pipe-message>abook --add-email-quiet<return>" "Add this sender to Abook"
      bind editor        <Tab> complete-query
    '';
  };
}
