{ inputs, ... }:
{
  # NOTE: This is not currently used on any servers.
  # This is a work in progress config copied from an existing (working) configuration.

  imports = [
    # Generic modules for QEMU virtual machines
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"

    inputs.srvos.nixosModules.mixins-cloud-init

    ./disko.nix
  ];

  networking.hostName = "vps1";

  system.stateVersion = "24.10";

  # No password can hash to !, so this disables password login for root
  users.users.root.hashedPassword = "!";

  # This is set to `false` by the srvos server profile, but because we're using
  # sshAgentAuth, it's more secure to enable passwords if there's no agent
  # security.sudo.wheelNeedsPassword = lib.mkForce true;

  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo.sshAgentAuth = true;

  users.users.robert = {
    isNormalUser = true;
    description = "non-root administrator account";

    group = "users";
    extraGroups = [ "wheel" ];

    home = "/home/robert";
    createHome = true;

    openssh.authorizedKeys.keyFiles = [
      ./users/robert/authorized_keys
    ];
  };

  virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  environment.systemPackages = [
    pkgs.docker-compose
  ];

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [
      "--accept-dns=false"
    ];
    # FIXME: agenix isn't installed yet
    authKeyFile = config.age.secrets.tailscale-vps1.path;
  };
}
