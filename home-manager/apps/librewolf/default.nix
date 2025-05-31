{ config, pkgs, inputs, ... }:
let newTabPage = "file://${pkgs.writeText "index.html" (builtins.readFile ./index.html)}";
in {
  config.home.file.".librewolf/librewolf.overrides.cfg".text = ''
    // sets the new tab page to our local newtab.
    ChromeUtils.importESModule("resource:///modules/AboutNewTab.sys.mjs").AboutNewTab.newTabURL = "${newTabPage}";

    // sets our home page to the same URL.
    pref("browser.startup.homepage", "${newTabPage}");

    // don't firefox sync the homepage, stops it overwriting on windows.
    pref("services.sync.prefs.sync.browser.startup.homepage", false);
  '';
  config.programs.librewolf = {
    enable = true;
    policies = { NoDefaultBookmarks = false; };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        extensions.packages =
          with inputs.firefox-addons.packages.${pkgs.system}; [
            darkreader
            sidebery
            violentmonkey
            userchrome-toggle-extended
            videospeed
            return-youtube-dislikes
            ublock-origin
            don-t-fuck-with-paste
            sponsorblock
            ublacklist
          ];
        userChrome = (builtins.readFile ./userChrome.css);
        userContent = (builtins.readFile ./userContent.css);
        bookmarks = {
          force = true;
          settings = import ./bookmarks.nix ++ [{
            name = "toolbar";
            toolbar = true;
            bookmarks = import ./bookmarks.nix;
          }];
        };
        #bookmarks.internal = false;
        search = {
          force = true;
          default = "ddg";
          engines = import ./search_engines.nix;
        };
        settings = {
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "browser.urlbar.trimHttps" = false;
          "browser.urlbar.trimURLs" = false;
          "permissions.default.shortcuts" =
            2; # dont allow sites overriding default shortcuts like ctrl+f
          "app.update.auto" = false;
          "browser.urlbar.suggest.calculator" =
            true; # Integrated calculator at urlbar
          "browser.urlbar.unitConversion.enabled" =
            true; # Integrated unit convertor at urlbar
          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuit" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.theme.dark-private-windows" = true;
          "browser.startup.page" = 3; # Restore previous session
          "dom.forms.autocomplete.formautofill" = false; # Disable autofill
          "extensions.formautofill.creditCards.enabled" =
            false; # Disable credit cards
          "dom.payments.defaults.saveAddress" = false; # Disable address save
          "general.autoScroll" = true; # Drag middle-mouse to scroll
          "services.sync.prefs.sync.general.autoScroll" =
            false; # Prevent disabling autoscroll
          "extensions.pocket.enabled" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" =
            true; # Allow userChrome.css
          "layout.css.color-mix.enabled" = true;
          "layout.css.has-selector.enabled" = true;
          "ui.systemUsesDarkTheme" = 1;
          "media.ffmpeg.vaapi.enabled" =
            true; # Enable hardware video acceleration
          "cookiebanners.ui.desktop.enabled" = true; # Reject cookie popups
          "cookiebanners.service.mode" =
            2; # TODO: if reject all is not an option i fear that it might accept cookies
          "devtools.command-button-screenshot.enabled" =
            true; # Scrolling screenshot of entire page
          "svg.context-properties.content.enabled" = true; # Sidebery styling
          "browser.tabs.hoverPreview.enabled" = false; # Disable tab previews
          "browser.tabs.hoverPreview.showThumbnails" =
            false; # Disable tab previews
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
          "extensions.autoDisableScopes" = 0; # enable plugins on first startup
          "extensions.enabledScopes" = 15; # enable plugins on first startup
          "shyfox.disable.floating.search" =
            true; # don't display urlbar floating on focus
          "browser.translations.automaticallyPopup" = false;
          "browser.uiCustomization.state" = import ./uiCustomization_state.nix;

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
          "trailhead.firstrun.didSeeAboutWelcome" =
            true; # Disable welcome splash
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.addedImportButton" = true;
          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
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
          "browser.startup.homepage" = "about:home";
          "browser.toolbars.bookmarks.visibility" = "newtab";
        };
      };
    };
  };
}
