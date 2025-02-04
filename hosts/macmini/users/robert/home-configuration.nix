{
  pkgs,
  perSystem,
  inputs,
  flake,
  users,
  ...
}:
{
  home.stateVersion = "24.11";

  imports = [ users.robert ];

  home.sessionVariables = {
    # My fish configuration uses this to check whether it should check if
    # the Touch ID PAM module is enabled. See: config/fish/functions/fish_greeting.fish
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };

  my.config.directory = "Developer/nix-dotfiles/config";
}
