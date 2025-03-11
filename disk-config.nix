# this file declares partitions for first install of nixos
# sources:
# Erase your darlings: immutable infrastructure for mutable systems
# ZFS - NixOS Wiki
# github disko - zfs-encrypted-root.nix
{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            zfs = {
              end = "-4G";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          # "com.sun:auto-snapshot" = "true";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              #keylocation = "file:///tmp/secret.key";
              keylocation = "prompt";
            };
            postCreateHook = "zfs snapshot zroot/root@blank";
            mountpoint = "/";

          };

          "nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };

          "var" = {
            type = "zfs_fs";
            options.mountpoint = "/var";
            mountpoint = "/var";
          };

          "persist" = {
            type = "zfs_fs";
            options.mountpoint = "/persist";
            mountpoint = "/persist";
          };

          "home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            mountpoint = "/home";
          };

          # README MORE: https://wiki.archlinux.org/title/ZFS#Swap_volume
          # "swap" = {
          #   type = "zfs_volume";
          #   size = "10M";
          #   content = {
          #     type = "swap";
          #   };
          #   options = {
          #     volblocksize = "4096";
          #     compression = "zle";
          #     logbias = "throughput";
          #     sync = "always";
          #     primarycache = "metadata";
          #     secondarycache = "none";
          #     "com.sun:auto-snapshot" = "false";
          #   };
          # };
        };
      };
    };
  };
}
