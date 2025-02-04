{
  flake,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default

    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot

    ./disko.nix
    ./minecraft
  ];

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "homeserver1";
  networking.hostId = "027fb931";
  networking.useDHCP = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.self.flake = inputs.self;

  age.secrets.tailscale-homeserver1.file = "${flake}/secrets/tailscale-homeserver1.age";
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-homeserver1.path;
    openFirewall = true;
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  users.users.robert = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "podman"
      "systemd-journal"
    ];
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/macbook-air/users/robert/authorized_keys"
      "${flake}/hosts/macmini/users/robert/authorized_keys"
    ];
  };
}
