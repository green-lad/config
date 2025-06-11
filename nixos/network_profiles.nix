environmentFile:
# generated via:
# sudo su -c "cd /etc/NetworkManager/system-connections && nix --extra-experimental-features 'nix-command flakes' run github:shymega/nm2nix/refactor\/fix-json-tmpfile | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixfmt-rfc-style"
{
  environmentFiles = [ environmentFile ];
  profiles = {
    fau_fm = {
      connection = {
        id = "fau";
        type = "wifi";
        permissions = "user:markus:;";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
      wifi = {
        ssid = "FAU.fm";
      };
      wifi-security = {
        group = "ccmp;tkip;";
        key-mgmt= "wpa-eap";
        pairwise = "ccmp;";
        proto = "rsn;";
      };
      "802-1x" = {
        anonymous-identity = "$fau_user";
        ca-cert = "/home/markus/.config/cat_installer/comodo.pem";
        eap = "peap;";
        identity = "$fau_user";
        password = "$fau_password";
        phase2-auth = "mschapv2";
      };
    };
    home_wlan = {
      connection = {
        id = "home_wlan";
        type = "wifi";
      };
      ipv4 = { method = "auto"; };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
      proxy = { };
      wifi = {
        mode = "infrastructure";
        ssid = "$home_wlan_ssid";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = "$home_wlan_psk";
      };
    };
  };
}
