{ pkgs, inputs }:
pkgs.mkShellNoCC {
  packages = [
    pkgs.nixos-rebuild
    pkgs.nixos-anywhere
    pkgs.age
    pkgs.lima
  ];
}
