{ ... }: {
  config.home.file = {
    ".moc/config".source = ./config;
    ".moc/keymap".source = ./keymap;
  };
}
