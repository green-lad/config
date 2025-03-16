{ hostname, ... }:
let 
  secretspath = builtins.toString input.sops_secrets;
in {
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    # defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;
    
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

    age = {
      # TODO: this seems wrong
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      imap-password = {};
      "keys/${hostname}/private" = {};
    };
  };
}  
