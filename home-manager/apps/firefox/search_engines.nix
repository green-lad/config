{
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

    icon = "https://wiki.nixos.org/favicon.png";
    updateInterval = 24 * 60 * 60 * 1000; # every day
    definedAliases = [ "@hmo" ];
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

    icon = "https://wiki.nixos.org/favicon.png";
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

    icon = "https://www.mozilla.org/media/protocol/img/logos/firefox/logo.fedb52c912d6.svg";
    updateInterval = 24 * 60 * 60 * 1000; # every day
    definedAliases = [ "@fe" ];
  };
}
