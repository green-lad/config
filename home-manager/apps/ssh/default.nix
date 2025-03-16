{ config, hostname, ... }: {
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github" = {
	host = "github";
        hostname = "github.com";
	user = "git";
	identitiesOnly = true;
	identityFile = [
	  "~/.ssh/id_ed25519"
	  # config.sops.secrets."keys/${hostname}/private".path
	];
      };
    };
  };
}
