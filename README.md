# My simple nix-darwin & NixOS (WSL) configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're trying to get set up with your own cross-platform NixOS, WSL, and
nix-darwin configuration!

This repo entirely supersedes [clo4/dotfiles](https://github.com/clo4/dotfiles).

## Structure

The goal of the directory structure is to be as simple and consistent as
possible.

- [`flake.nix`](./flake.nix) is where the systems are declared and the modules
  they need are defined.
- [`systems/`](./systems) stores the configuration for each machine.
  - `home.nix` contains the home configuration shared by each system
  - `host.nix` contains the system configuration shared by each system
  - `<host>/home.nix` is the system-specific config
  - `<host>/host.nix` is the system-specific config
- [`programs/`](./programs) is where I move my program configuration when it
  gets too long to store in my home config. By default, programs are configured
  wherever is most appropriate, and when they start to take up too much room or
  require certain things enabled on particular systems, I move the configuration
  to a module and put it in this directory.
- [`modules/home/`](./modules/home) is where home-manager modules are defined.
  The home modules are imported by `systems/home.nix`, which allows any file
  imported by the home configuration to use these modules.

When I eventually have to define my own modules for whatever reason, they'll go
in either `modules/host` or `modules/home`.

## My PC situation

The GPU in my Intel machine has died entirely, so until I resolve that (which,
to be clear, I don't have the money to do right now) I can't make any updates to
my WSL config. So that's on pause. My Mac, which was already my main device, is
now my only device... yay.
