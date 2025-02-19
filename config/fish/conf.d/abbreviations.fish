# General shell helpers.
# These are commands that I type enough that I need them
# to be faster to type.
abbr -a - "cd -"
abbr -a .. "cd .."
abbr -a cpr "cp -r"
abbr -a % "xargs -I % --"
abbr -a f "fzf |"
abbr -a fm "fzf --multi |"
abbr -a rmf "rm -rf"
abbr -a md "mkdir -p"
abbr -a cmv "command -v"
abbr -a l "ls -lAhH"

if set -q IS_DARWIN
    abbr -a pb pbcopy
    abbr -a pbp pbpaste
end

abbr -a n nix
abbr -a nxi nix
abbr -a nd "nix develop"
abbr -a nb "nix build"
abbr -a nr "nix run"
abbr -a ns "nix shell"
abbr -a nre "nix repl"
abbr -a nf "nix fmt"
abbr -a nfs "nix flake show"
abbr -a nfl "nix flake lock"
abbr -a nfu "nix flake update"
abbr -a nfuc "nix flake update --commit-lock-file"
abbr -a nfc "nix flake check"
abbr -a nfi "nix flake init"
abbr -a nfit "nix flake init --template"

# Random abbreviations that are easier to type on some layouts, because I hop
# around a lot.
abbr -a nv nvim
abbr -a he hx

abbr -a t tmux
abbr -a ta "tmux attach; or tmux"
abbr -a tk "tmux kill-session"
abbr -a tl "tmux list-sessions"

abbr -a ts tailscale
abbr -a tsd tailscaled
abbr -a tf terraform # not installed globally, used in projects

abbr -a co cargo
abbr -a cob "cargo build"
abbr -a cor "cargo run"
abbr -a corr "cargo run --release"
abbr -a cot "cargo test"
abbr -a coa "cargo add"
abbr -a coc "cargo check"

abbr -a g lazygit
abbr -a ",a" "git add"
abbr -a ",ap" "git add --patch"
abbr -a ",aa" "git add -A"
abbr -a ",r" "git restore"
abbr -a ",rs" "git restore --staged"
abbr -a ",re" "git reset"
abbr -a ",rv" "git remote -v"
abbr -a ",c" "git commit"
abbr -a ",ca" "git commit --amend"
abbr -a ",d" "git diff"
abbr -a ",dc" "git diff --cached"
abbr -a ",m" "git merge"
abbr -a ",s" "git status"
abbr -a ",p" "git push"
abbr -a ",pf" "git push --force-with-lease"
abbr -a ",pu" "git pull"
abbr -a ",f" "git fetch"
abbr -a ",fu" "git fetch upstream"
abbr -a ",sw" "git switch"
abbr -a ",sc" "git switch -c"
abbr -a ",b" "git branch"
abbr -a ",l" "git log"
