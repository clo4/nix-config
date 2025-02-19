# clo4's configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're getting stuck configuring your own Nix flake setup! I currently
actively maintain my nix-darwin and standalone Home Manager configurations, but
supporting NixOS or WSL would be as simple as adding another entry to `hosts`.

Traditional Nix system configuration requires a rebuild to apply, but I found
that this was slowing me down and disincentivising me from changing things on my
system. This time around, everything about the way my config is structured is to
allow me to iterate raplidly:

- Home Manager symlinks my config to the right location. This results in the
  normal instant feedback loop of editing your dotfiles, but with the certainty
  that you can reapply it at any point exactly the same way it is now.
- The flake uses [Blueprint](https://github.com/numtide/blueprint), which gets
  rid of all the glue code I would otherwise need. Creating hosts is as simple
  as creating a directory in `hosts`, or making a package, creating a file in
  `packages`.

Program configuration is all stored in [config](/config).

My shared Home Manager config applies this configuration:
[modules/home/robert.nix](/modules/home/robert.nix)

This configuration is applied per-host with tweaks on top of it: [hosts](/hosts)

## Custom stuff

- Using Fish as my interactive shell, but delegating all initial setup to ZSH.
  This means the login shell is always guaranteed to be POSIX-enough to work,
  but I still get to benefit from my shell of choice.
- Reimplemented a Fish plugin manager in Nix for declarative plugins with
  imperative configuration. Plugins will not clutter up my config, nor can they
  accidentally clobber any files. Updates are done by updating the plugin
  package.
- Using
  [mattwparas' fork of Helix](https://github.com/mattwparas/helix/tree/steel-event-system)
  with support for plugins, though I haven't set up or written any plugins yet.
  Steel language server integration works.
- Homebrew is installed automatically and managed declaratively with
  [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)

More of my tweaks will be documented in the future.

## Hosts

- `macmini`
  - This is my main dev machine. Most configuration will be up-to-date for it.
    It's a nix-darwin system that also configures my user using Home Manager.
- `macbook-air`
  - This is my secondary computer. It's owned by my partner, so I haven't
    installed nix-darwin. Instead, this is a standalone configuration.

In the future, I'll likely have a WSL host and NixOS host for homelab stuff.

### Bootstrapping homeserver1

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:clo4/nix-dotfiles/vps#homeserver1-install
```
