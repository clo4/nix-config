for p in XDG_DATA_DIRS XDG_CONFIG_DIRS TERMINFO_DIRS
    set --path $p $$p
end

# Standalone Home Manager leaves Fish to reconstruct its own PATH, which
# takes the existing path from ZSH, puts /etc/paths and /etc/paths.d first,
# then appends the existing non-duplicate entries to the end.
# This results in the Nix entries being at the tail of the PATH, which isn't
# ideal. The solution is to add all profile bin directories to the front
# and deduplicate them (deduping is handled in config.fish)
for path in (string split ' ' $NIX_PROFILES)
    set --global fish_user_paths $path/bin $fish_user_paths
end

command -q hx; and set -x EDITOR hx

# Setting this to an empty string makes direnv silent
set -x DIRENV_LOG_FORMAT

set -x PSQL_HISTORY $HOME/.local/share/psql/psql_history
set -l psql_history_dir (path dirname $PSQL_HISTORY)
if not test -d $psql_history_dir
    mkdir -p $psql_history_dir
end

set -x SQLITE_HISTORY $HOME/.local/share/sqlite3/sqlite_history
set -l sqlite_history_dir (path dirname $SQLITE_HISTORY)
if not test -d $sqlite_history_dir
    mkdir -p $sqlite_history_dir
end

if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
    set --append fish_user_paths /opt/homebrew/bin
end

if set -q GHOSTTY_BIN_DIR; and not contains -- $GHOSTTY_BIN_DIR $PATH
    set --append PATH $GHOSTTY_BIN_DIR
end

# Fish comes with some builtin aliases for ls, which we don't want.
# Instead, `l` is an abbreviation defined in the abbreviations.fish file.
functions -e la ll
