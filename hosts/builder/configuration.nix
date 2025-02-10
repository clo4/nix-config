{
  pkgs,
  inputs,
  flake,
  modulesPath,
  ...
}:
{
  imports = [
    ./disk.nix
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  documentation.enable = false;

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
  ];
  boot.loader.systemd-boot.enable = true;

  virtualisation.rosetta.enable = true;

  system.stateVersion = "24.11";

  # Linux 6.11 broke Rosetta, but it seems to be on Apple to fix it:
  # https://github.com/utmapp/UTM/discussions/6799#discussioncomment-11247028
  # 6.6 is the latest supported release that won't break it.
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  nix.channel.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.log-lines = 25;
  nix.gc.automatic = true;

  networking.hostName = "builder";
  networking.useNetworkd = true;
  networking.useDHCP = true;

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keyFiles = [ "${flake}/users/robert/authorized_keys" ];

  # users.users.root.hashedPassword = "!";
  # users.users.builder = {
  #   openssh.authorizedKeys.keyFiles = [ "${flake}/users/robert/authorized_keys" ];
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ];
  # };
  # security.sudo.wheelNeedsPassword = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };
  };

  # TODO: At some point I'd like to support full impermanence. There is no reason
  # for the builder to be stateful.
}
