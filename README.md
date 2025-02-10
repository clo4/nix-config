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

## Linux builder on aarch64-darwin

This is still just in the experimentation phase. The following is my thought
process.

<details>

I want to have a way to build x86_64-linux software (mainly, NixOS itself) from
my aarch64-darwin machines. This requires a builder machine running Linux. That
builder doesn't have to be a physical system - it could just be a VM running on
the same device, so long as it's accessible by SSH.

The builder doesn't have to run NixOS; the only requirement is that Nix is
installed. However, running NixOS makes configuring it significantly easier,
which is important because this builder will be running on two devices.

The VM should use Virtualization.Framework as its VM backend. It will be
aarch64-linux so that the host system doesn't have to emulate x86-64
instructions. Rosetta will be available so that x86-64 software can be built at
near-native speed, because using emulation is _far_ too slow.

The builder also has to run a specific Linux kernel version, since versions
newer than 6.10 break Rosetta (this is Apple's fault).

These requirements mean that Docker (and other containerization solutions) are
not viable, since I need full control over the system.

The best options right now seem to be:

- Tart: https://tart.run
- Lima: https://lima-vm.io
- UTM: https://getutm.app

Tart is not "free software", while Lima and UTM are. UTM requires that the
application is running (can run without dock icon, but that introduces some
weirdness), while Lima is fully headless. However, Lima requires more
configuration and seems (?) to have a little more overhead to get working -- I'm
trying to optimize this for being really, really simple.

### Running with UTM

The bootstrap process should probably look something like this:

1. Create a VM with the NixOS ISO named "builder"
2. Run something like
   `nixos-rebuild switch --flake github:clo4/nix-dotfiles#builder` (which could
   automatically configure the disk too)
3. ... Profit?

Currently:

```bash
sudo nix --extra-experimental-options 'nix-command flakes' run github:clo4/nix-dotfiles/vps#builder-install
```

</details>
