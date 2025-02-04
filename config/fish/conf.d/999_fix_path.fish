# Standalone Home Manager leaves Fish to reconstruct its own PATH, which
# takes the existing path from ZSH, puts the contents of /etc/paths and
# /etc/paths.d first, then appends the existing non-duplicate entries to
# the end. This results in the Nix entries being at the tail of the PATH,
# which isn't ideal. The solution is to add all profile bin directories
# to the front and deduplicate them.
#
# Without the check before executing, the NIX_PROFILES directories will
# always be moved to the front, even when entering a nested `nix develop`
# shell, which could result in the wrong program being executed if specified
# by both the user environment and dev shell.
if set -q IS_DARWIN; and not set -q __NIX_PROFILES_HAVE_BEEN_MOVED
    for path in (string split ' ' $NIX_PROFILES)
        set -g PATH $path/bin $PATH
    end
    set -gx __NIX_PROFILES_HAVE_BEEN_MOVED
end

# Deduplicate PATH because it might contain dupes after the handoff from ZSH.
set -l new_path
for path in $PATH
    if not contains -- $path $new_path
        set new_path $new_path $path
    end
end
set -gx PATH $new_path
