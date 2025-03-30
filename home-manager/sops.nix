{ hostname, inputs, ... }:
let 
  secretspath = builtins.toString inputs.sops_secrets;
in {
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = false;
    
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

    secrets = {
      imap_password = {};
      wlan_password = {};
      "keys/${hostname}/private" = {};
    };
  };
}  
