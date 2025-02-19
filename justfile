switch-server:
    nixos-rebuild switch --target-host robert@homeserver1 --build-host robert@homeserver1 --fast --use-remote-sudo --flake .#homeserver1

