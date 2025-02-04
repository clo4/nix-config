# These variables will not be pathified by Fish by default, but
# they behave like path variables, so it makes sense to treat them
# as such.
for p in XDG_DATA_DIRS XDG_CONFIG_DIRS TERMINFO_DIRS
    set --path $p $$p
end

# It's possible that `hx` isn't available if I totally bungle my $PATH
if command -q hx
    set -x EDITOR hx
else
    set -x EDITOR vim
end

# Setting this to an empty string makes direnv silent
set -x DIRENV_LOG_FORMAT

# SQLite and Postgres both store their history files in a stupid location
# by default, so this moves the histories to the data dir where they belong.
set -x PSQL_HISTORY $HOME/.local/share/psql/psql_history
set -l psql_history_dir (path dirname $PSQL_HISTORY)
test -d $psql_history_dir; or mkdir -p $psql_history_dir

set -x SQLITE_HISTORY $HOME/.local/share/sqlite3/sqlite_history
set -l sqlite_history_dir (path dirname $SQLITE_HISTORY)
test -d $sqlite_history_dir; or mkdir -p $sqlite_history_dir

# Homebrew should be available, but I don't want anything installed by
# it to take precendence over anything installed by Nix.
if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
    set --append fish_user_paths /opt/homebrew/bin
end

# Fish comes with some builtin aliases for ls, which we don't want.
# Instead, `l` is an abbreviation defined in the abbreviations.fish file.
functions -e la ll
