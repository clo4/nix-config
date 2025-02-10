{
  pkgs,
  inputs,
  flake,
  ...
}:
{
  imports = [
    ./disk.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "builder";
  documentation.enable = false;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.11";

  # Linux 6.11 broke Rosetta, but it seems to be on Apple to fix it:
  # https://github.com/utmapp/UTM/discussions/6799#discussioncomment-11247028
  # 6.6 is the latest supported release that won't break it.
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = import "${flake}/users/robert/public-keys.nix";
}
