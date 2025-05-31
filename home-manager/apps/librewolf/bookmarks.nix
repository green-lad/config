[
  {
    name = "wikipedia";
    tags = [ "wiki" ];
    keyword = "wiki";
    url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
  }
  {
    name = "Nix sites";
    bookmarks = [
      {
        name = "homepage";
        bookmarks = [
          {
            name = "nix org";
            url = "https://nixos.org/";
          }
        ];
      }
      {
        name = "wiki";
        tags = [ "wiki" "nix" ];
        url = "https://wiki.nixos.org/";
      }
    ];
  }
]
