{
  pkgs,
  inputs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    perSystem.agenix.default
    pkgs.nixos-rebuild
    pkgs.nixos-anywhere
    pkgs.age
    pkgs.lima
  ];
}
