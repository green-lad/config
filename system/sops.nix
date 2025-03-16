{ hostname, inputs, ... }:
let 
  secretspath = builtins.toString input.sops_secrets;
in {
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    # defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      "keys/${hostname}/public" = {};
    };
  };
}  
