let interval = 24 * 60 * 60 * 1000;
in {
  "google".metaData.hidden = true;
  "bing".metaData.hidden = true;
  "home-manager options" = {
    urls = [
      {
        template = "https://home-manager-options.extranix.com";
        params = [
          {
            name = "release";
            value = "master";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@hmo" ];
  };

  "github nix code search" = {
    urls = [
      {
        template = "https://github.com/search?q={searchTerms}%20language%3ANix&type=code";
      }
    ];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@gn" ];
  };

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
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@np" ];
  };

  "nixos options" = {
    urls = [
      {
        template = "https://search.nixos.org/options";
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
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@no" ];
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
    icon = "https://www.mozilla.org/media/protocol/img/logos/firefox/logo.fedb52c912d6.svg";
    updateInterval = interval;
    definedAliases = [ "@fe" ];
  };

  "youtube" = {
    urls = [
      {
        template = "youtube.de/results";
        params = [
          {
            name = "search_query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://www.youtube.com/s/desktop/716a93d8/img/logos/favicon.ico";
    # icon = "https://www.gstatic.com/youtube/img/branding/youtubelogo/svg/youtubelogo.svg";
    updateInterval = interval;
    definedAliases = [ "@y" ];
  };

  "chefkoch" = {
    urls = [
      {
        template = "https://www.chefkoch.de/rs/s0/{searchTerms}/Rezepte.html";
      }
    ];
    icon = "https://img.chefkoch-cdn.de/favicon.ico";
    updateInterval = interval;
    definedAliases = [ "@ch" ];
  };

  "google maps" = {
    urls = [
      {
        template = "https://www.google.de/maps/place/{searchTerms}";
      }
    ];
    icon = "https://www.google.com/images/branding/product/ico/maps15_bnuw3a_32dp.ico";
    updateInterval = interval;
    definedAliases = [ "@m" ];
  };
}
