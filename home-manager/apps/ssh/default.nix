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
	  config.sops.secrets."keys/${hostname}/private".path
	];
      };
    };
  };
}
