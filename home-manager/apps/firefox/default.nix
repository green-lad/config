{ config, pkgs, inputs, ... }: {
  programs.firefox = {
  # in librewolf the configuration of bookmarks is not working with the configuration of firefox
  # programs.librewolf = {
    enable = true;
    policies = {
      NoDefaultBookmarks = false;
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          darkreader
          sidebery
          violentmonkey
          userchrome-toggle
          videospeed
          return-youtube-dislikes
          ublock-origin
          don-t-fuck-with-paste
          sponsorblock
          ublacklist
        ];
        userChrome = (builtins.readFile ./userChrome.css);
        userContent = (builtins.readFile ./userContent.css);
        bookmarks = import ./bookmarks.nix ++ [{
          name = "toolbar";
          toolbar = true;
          bookmarks = import ./bookmarks.nix;
        }];
        search = {
          force = true;
          default = "DuckDuckGo";
          engines = {
            "Google".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "nix packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconUpdateURL = "https://wiki.nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@np" ];
            };
            "firefox extensions" = {
              urls = [
                {
                  template = "https://addons.mozilla.org/en-US/firefox/search/";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              iconUpdateURL = "https://www.mozilla.org/media/protocol/img/logos/firefox/logo.fedb52c912d6.svg";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@fe" ];
            };
          };
        };
        settings = {
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "browser.urlbar.trimHttps" = false;
          "browser.urlbar.trimURLs" = false;
          "permissions.default.shortcuts" = 2; # dont allow sites overriding default shortcuts like ctrl+f
          "app.update.auto" = false;
          "browser.urlbar.suggest.calculator" = true; # Integrated calculator at urlbar
          "browser.urlbar.unitConversion.enabled" = true; # Integrated unit convertor at urlbar
          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuit" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.theme.dark-private-windows" = true;
          "browser.startup.page" = 3; # Restore previous session
          "dom.forms.autocomplete.formautofill" = false; # Disable autofill
          "extensions.formautofill.creditCards.enabled" = false; # Disable credit cards
          "dom.payments.defaults.saveAddress" = false; # Disable address save
          "general.autoScroll" = true; # Drag middle-mouse to scroll
          "services.sync.prefs.sync.general.autoScroll" = false; # Prevent disabling autoscroll
          "extensions.pocket.enabled" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Allow userChrome.css
          "layout.css.color-mix.enabled" = true;
          "layout.css.has-selector.enabled" = true;
          "ui.systemUsesDarkTheme" = 1;
          "media.ffmpeg.vaapi.enabled" = true; # Enable hardware video acceleration
          "cookiebanners.ui.desktop.enabled" = true; # Reject cookie popups
          "cookiebanners.service.mode" = 2; # TODO: if reject all is not an option i fear that it might accept cookies
          "devtools.command-button-screenshot.enabled" = true; # Scrolling screenshot of entire page
          "svg.context-properties.content.enabled" = true; # Sidebery styling
          "browser.tabs.hoverPreview.enabled" = false; # Disable tab previews
          "browser.tabs.hoverPreview.showThumbnails" = false; # Disable tab previews
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "widget.use-xdg-desktop-portal.mime-handler" = 1;
          "widget.gtk.ignore-bogus-leave-notify" = 1;
          "browser.search.defaultenginename" = "duckduckgo";
          "browser.tabs.tabmanager.enabled" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.showSearchSuggestionsFirst" = false;
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.addons" = false;
          "browser.urlbar.suggest.pocket" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.topSitesRows" = 4;
          "browser.newtabpage.pinned" = ''[{"url":"https://www.studon.fau.de/studon/ilias.php?baseClass=ilrepositorygui&reloadpublic=1&cmd=frameset&ref_id=1","label":"studon.fau","baseDomain":"studon.fau.de"},{"url":"https://www.kleinanzeigen.de/","baseDomain":"kleinanzeigen.de"},{"url":"https://faumail.uni-erlangen.de/","baseDomain":"faumail.uni-erlangen.de"},{"url":"https://localhost:722","label":"miniflux"},{"url":"https://www.scribd.com/document/498201474/Language-Proof-and-Logic-2nd-D-Barker-Plummer-J-Barwise-J-Etchemendy","label":"scribd","baseDomain":"scribd.com"},{"url":"https://amazon.de","label":"amazon","baseDomain":"amazon.de"},{"url":"https://www.sparkasse-nuernberg.de/de/home.html","baseDomain":"sparkasse-nuernberg.de"},{"url":"https://www.consorsbank.de/home","label":"consorsbank","baseDomain":"consorsbank.de"},{"url":"https://www.thingiverse.com/","label":"thingiverse","baseDomain":"thingiverse.com"},{"url":"https://github.com/green-lad","label":"github","baseDomain":"github.com"},{"url":"http://homeassistant:8123/","label":"homeassistant","baseDomain":"homeassistant"},{"url":"https://fritz.box/","label":"fritz","baseDomain":"fritz.box"},{"url":"https://my.remarkable.com/","label":"my.remarkable","baseDomain":"my.remarkable.com"},{"url":"http://192.168.178.55","label":"pocketnc","baseDomain":"192.168.178.55"},{"url":"https://www.campo.fau.de/qisserver/pages/cs/sys/portal/hisinoneStartPage.faces","label":"campo.fau","baseDomain":"campo.fau.de"},{"url":"http://greenlad.xyz/","label":"home","baseDomain":"greenlad.xyz"},{"url":"https://fsi.cs.fau.de/","label":"fsi.cs.fau","baseDomain":"fsi.cs.fau.de"},{"url":"https://www.vgn.de/","baseDomain":"vgn.de"},{"url":"https://sim.pentamachine.com/","label":"pocket_nc_simulator","baseDomain":"sim.pentamachine.com"},{"url":"https://chomsky.info/","label":"chomsky","baseDomain":"chomsky.info"},{"url":"https://leanpub.com/","label":"leanpub","baseDomain":"leanpub.com"},{"url":"http://localhost:5232","label":"radicale","baseDomain":"localhost"},{"url":"https://www.youtube.com","label":"youtube","baseDomain":"youtube.com"},{"url":"https://www.twitch.tv/barbarousking","label":"twitch","baseDomain":"twitch.tv"},null,null,{"url":"https://maps.google.de","label":"maps","baseDomain":"maps.google.de"},{"url":"https://www.currentaffairs.org/","baseDomain":"currentaffairs.org"},{"url":"https://www.dhl.de/de/privatkunden/dhl-sendungsverfolgung.html","label":"DHL Sendungsverfolgung","baseDomain":"dhl.de"},{"url":"https://www.dict.cc/","baseDomain":"dict.cc"},{"url":"http://netflix.com","label":"Netflix","baseDomain":"netflix.com"}]'';
          "extensions.autoDisableScopes" = 0; # enable plugins on first startup
          "extensions.enabledScopes" = 15; # enable plugins on first startup
          "shyfox.disable.floating.search" = true; # don't display urlbar floating on focus
          "browser.translations.automaticallyPopup" = false;
          "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["sponsorblocker_ajay_app-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","ublock0_raymondhill_net-browser-action","tranquility_ushnisha_com-browser-action","firefox_tampermonkey_net-browser-action","adblockultimate_adblockultimate_net-browser-action","adguardadblocker_adguard_com-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_2dcee44e-e1a9-40eb-afb2-708888c50200_-browser-action","firefox_audd_tech-browser-action","addon_darkreader_org-browser-action","_c7cf295f-fc8b-4218-91b1-2a2ea572da9f_-browser-action","_7be2ba16-0f1e-4d93-9ebc-5164397477a9_-browser-action","playbackspeed_waldemar_b-browser-action","_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action","dontfuckwithpaste_raim_ist-browser-action","_ublacklist-browser-action"],"nav-bar":["userchrome-toggle_joolee_nl-browser-action","back-button","forward-button","stop-reload-button","vertical-spacer","customizableui-special-spring1","urlbar-container","zoom-controls","unified-extensions-button","reset-pbm-toolbar-button","newtaboverride_agenedia_com-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","alltabs-button","history-panelmenu","downloads-button","userchrome-toggle-extended_n2ezr_ru-browser-action","personal-bookmarks","customizableui-special-spring16","home-button","developer-button","fullscreen-button","preferences-button"],"vertical-tabs":[],"PersonalToolbar":[]},"seen":["save-to-pocket-button","developer-button","adblockultimate_adblockultimate_net-browser-action","adguardadblocker_adguard_com-browser-action","firefox_tampermonkey_net-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_2dcee44e-e1a9-40eb-afb2-708888c50200_-browser-action","firefox_audd_tech-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","addon_darkreader_org-browser-action","newtaboverride_agenedia_com-browser-action","userchrome-toggle-extended_n2ezr_ru-browser-action","tranquility_ushnisha_com-browser-action","userchrome-toggle_joolee_nl-browser-action","_c7cf295f-fc8b-4218-91b1-2a2ea572da9f_-browser-action","_7be2ba16-0f1e-4d93-9ebc-5164397477a9_-browser-action","playbackspeed_waldemar_b-browser-action","_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action","ublock0_raymondhill_net-browser-action","dontfuckwithpaste_raim_ist-browser-action","_ublacklist-browser-action","sponsorblocker_ajay_app-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area","vertical-tabs"],"currentVersion":21,"newElementCount":47}'';

          # Disable irritating first-run stuff
          "browser.disableResetPrompt" = true;
          "browser.download.panel.shown" = true;
          "browser.feeds.showFirstRunUI" = false;
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "browser.rights.3.shown" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.startup.homepage_override.mstone" = "ignore";
          "browser.uitour.enabled" = false;
          "startup.homepage_override_url" = "";
          "trailhead.firstrun.didSeeAboutWelcome" = true; # Disable welcome splash
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.addedImportButton" = true;
          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.toolbars.bookmarks.visibility" = "newtab";
        };
      };
    };
  };
}

