let interval = 24 * 60 * 60 * 1000;
in {
  "google".metaData.hidden = true;
  "bing".metaData.hidden = true;
  "home-manager options" = {
    urls = [{
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
    }];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@hmo" ];
  };

  "github code search" = {
    urls =
      [{ template = "https://github.com/search?q=%22{searchTerms}%22&type=code"; }];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@g" ];
  };

  "github nix code search" = {
    urls = [{
      template =
        "https://github.com/search?q={searchTerms}%20language%3ANix&type=code";
    }];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@gn" ];
  };

  "nix packages" = {
    urls = [{
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
    }];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@np" ];
  };

  "nixos options" = {
    urls = [{
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
    }];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = interval;
    definedAliases = [ "@no" ];
  };

  "firefox extensions" = {
    urls = [{
      template = "https://addons.mozilla.org/en-US/firefox/search/";
      params = [{
        name = "q";
        value = "{searchTerms}";
      }];
    }];
    icon =
      "https://www.mozilla.org/media/protocol/img/logos/firefox/logo.fedb52c912d6.svg";
    updateInterval = interval;
    definedAliases = [ "@fe" ];
  };

  "youtube" = {
    urls = [{
      template = "youtube.de/results";
      params = [{
        name = "search_query";
        value = "{searchTerms}";
      }];
    }];
    icon = "https://www.youtube.com/s/desktop/716a93d8/img/logos/favicon.ico";
    # icon = "https://www.gstatic.com/youtube/img/branding/youtubelogo/svg/youtubelogo.svg";
    updateInterval = interval;
    definedAliases = [ "@y" ];
  };

  "chefkoch" = {
    urls = [{
      template = "https://www.chefkoch.de/rs/s0/{searchTerms}/Rezepte.html";
    }];
    icon = "https://img.chefkoch-cdn.de/favicon.ico";
    updateInterval = interval;
    definedAliases = [ "@ch" ];
  };

  "google maps" = {
    urls = [{ template = "https://www.google.de/maps/place/{searchTerms}"; }];
    icon =
      "https://www.google.com/images/branding/product/ico/maps15_bnuw3a_32dp.ico";
    updateInterval = interval;
    definedAliases = [ "@m" ];
  };

  "crossref" = {
    urls = [{
      template =
        "https://search.crossref.org/search/works?q={searchTerms}&from_ui=yes";
    }];
    icon = "https://assets.crossref.org/favicon/android-chrome-192x192.png";
    updateInterval = interval;
    definedAliases = [ "@rfc" ];
  };

  "arxiv" = {
    urls = [{
      template =
        "https://arxiv.org/search/?query={searchTerms}&searchtype=all&source=header";
    }];
    icon =
      "https://static.arxiv.org/static/base/1.0.0a5/images/arxiv-logo-one-color-white.svg";
    updateInterval = interval;
    definedAliases = [ "@rfa" ];
  };

  "dl.acm.org" = {
    urls = [{
      template = "https://dl.acm.org/action/doSearch?AllField={searchTerms}";
    }];
    icon =
      "https://dl.acm.org/pb-assets/head-metadata/apple-touch-icon-1574252172393.png";
    updateInterval = interval;
    definedAliases = [ "@rfacm" ];
  };

  "google scholar" = {
    urls =
      [{ template = "https://scholar.google.com/scholar?q={searchTerms}"; }];
    icon = "https://scholar.google.com/favicon.ico";
    updateInterval = interval;
    definedAliases = [ "@rfg" ];
  };

  "rust book" = {
    urls =
      [{ template = "https://doc.rust-lang.org/book/?search={searchTerms}"; }];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@rb" ];
  };

  "rust language reference" = {
    urls = [{
      template =
        "https://doc.rust-lang.org/reference/index.html?search={searchTerms}";
    }];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@rr" ];
  };

  "rust themis" = {
    urls = [{
      template =
        "file:///home/markus/themis/target/doc/bench_client/index.html?search={searchTerms}";
    }];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@rt" ];
  };

  "rust by examlpe" = {
    urls = [{
      template =
        "https://doc.rust-lang.org/rust-by-example/index.html?search={searchTerms}";
    }];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@re" ];
  };

  "helix config" = {
    urls = [{
      template =
        "https://docs.helix-editor.com/editor.html?search={searchTerms}";
    }];
    icon = "https://helix-editor.com/favicon.svg";
    updateInterval = interval;
    definedAliases = [ "@hc" ];
  };

  "thingiverse" = {
    urls =
      [{ template = "https://www.thingiverse.com/search?q={searchTerms}"; }];
    icon = "https://cdn.thingiverse.com/site/img/favicons/favicon-192x192.png";
    updateInterval = interval;
    definedAliases = [ "@th" ];
  };

  "amazon" = {
    urls =
      [{ template = "https://www.amazon.de/s?k={searchTerms}"; }];
    icon = "https://www.amazon.de/favicon.ico";
    updateInterval = interval;
    definedAliases = [ "@a" ];
  };
}
