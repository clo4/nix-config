{
  inputs,
  pkgs,
  lib,
  perSystem,
  flake,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment

    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  users.users.robert = {
    description = "Robert";
    home = "/Users/robert";
  };

  # This needs to be reapplied after each system update
  security.pam.enableSudoTouchIdAuth = true;

  networking.hostName = "macmini";

  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  home-manager.backupFileExtension = "hm-backup";

  nix-homebrew.enable = true;
  # A user needs to own the prefix, so we'll make it my account
  nix-homebrew.user = "robert";

  environment.systemPackages = [
    pkgs.fish
    pkgs.mosh
  ];

  # Not sure about adding in vendor_conf.d because tools can just dump their init into it,
  # and because it will be included in a directory in $NIX_PROFILES, therefore
  # also $XDG_DATA_DIRS, it will be sourced during startup. This is probably fine, but
  # I want total control over what runs in my fish config.
  environment.pathsToLink = [
    # "/share/fish/vendor_conf.d"
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.channel.enable = false;
  # TODO: should I make 'robert' a trusted user?
  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;
}
