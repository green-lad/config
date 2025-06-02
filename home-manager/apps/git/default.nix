{ ... }: {
  programs.git = {
    enable = true;
    userName = "Markus Schoetz";
    userEmail = "markus.schoetz@fau.de";
    extraConfig = {
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        enable = true;
        navigate = true;
      };
      merge = { conflictstyle = "zdiff3"; };
    };
  };
}
