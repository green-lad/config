- enable flakes
```
echo "experimental-features = nix-command flake" >> /etc/nix/nix.conf
```

- get info about package
```
nix-repl
:l <nixpkgs>
:e pkgs.<package stuff>
```

- build env with package (here python3 with numpy)
```
:l <nixpkgs>
:b python3.withPackages (p: [p.numpy])
```

- get info about flake
```
nix-repl
x = builtins.getFlake "github:..."
:e x.<flake stuff>
```

- rebuild system (use "--flake path:." if files got moved)
```
sudo nixos-rebuild switch --flake .
```

- rebuild home-manager (use "--flake path:." if files got moved)
```
home-manager switch --flake .
```

- generate age key for sops (use ssh-add <private key> if the key was not generate on the machine)
```
ssh-keygen -t ed25519 -C "example@example.com" -f ~/.ssh/id_ed25519
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
age-keygen -y ~/.config/sops/age/keys.txt
```

- after key changes
```
sops updatekeys secrets.yaml
```

- evaluate nix expression, pretty print it and copy it to clipboard
```
nix-instantiate --eval <file/expression> | nixfmt | xsel -b
```
