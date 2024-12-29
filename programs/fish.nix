{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.programs.fish;
  # This is a no-op function that is only used by Helix to highlight an indented
  # string in the correct language. The highlight query is defined in the
  # helix.nix module.
  language = name: text: text;
  alias = name: {
    wraps = name;
    body = "${name} $argv";
  };
in
{
  options.my.programs.fish = {
    enable = mkEnableOption "my fish configuration";

    enableInteractiveCommandNotFound = mkEnableOption "my command not found handler using comma" // {
      default = false;
    }; # This is broken but `use` basically removes the need for it

    enableWslFunctions = mkEnableOption "my fish wsl alias functions";

    enableGreetingTouchIdCheck = mkEnableOption "a check for pam_tid.so on startup";

    setupNixEnv = mkEnableOption "configuration to set up the Nix environment (unnecessary when managed by NixOS or nix-darwin)";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableInteractiveCommandNotFound {
      home.packages = [ pkgs.gum ];

      programs.nix-index.enable = true;
      programs.nix-index.enableFishIntegration = false;

      programs.fish.functions.fish_command_not_found = language "fish" ''
        # Bail if the user is trying to run an executable file or doesn't want
        # to run the command with Nix
        if string match -q -- '*/*' $argv[1]
          or not gum confirm --selected.background=2 "Run with Nix?"
          __fish_default_command_not_found_handler $argv
          return
        end

        set choices (nix-locate --whole-name --minimal --at-root --top-level -- /bin/$argv[1] | sed 's/\\\\.out$//')

        if is_empty $choices
          echo "Failed to find a match. You might need to run `nix-index` again :)"
          return
        end

        set chosen (gum filter --select-if-one --height 20 --fuzzy --sort -- $choices)

        if test $status != 0
          return
        end

        echo -s -- (set_color green) "Success!" (set_color reset) " You can now run `" (set_color -i) $argv[1] (set_color reset) "` in this session."
        pkg $chosen
      '';

      programs.fish.interactiveShellInit = language "fish" ''
        # It's not necessarily an error to type the wrong command because you can still try
        # to execute it afterwards, so make the color of an unknown command less aggressive
        set -g fish_color_error brblue
      '';
    })

    (mkIf cfg.setupNixEnv {
      programs.fish.plugins = [
        {
          name = "nix-env.fish";
          src = inputs.fish-nix-env;
        }
      ];
    })

    (mkIf cfg.enableWslFunctions {
      programs.fish.functions.wsl = alias "wsl.exe";
    })

    (mkIf cfg.enableGreetingTouchIdCheck {
      home.packages = [ pkgs.gum ];

      programs.fish.functions.fish_greeting = language "fish" ''
        if not grep -qE '^auth\\s+sufficient\\s+pam_tid\\.so' /etc/pam.d/sudo
          echo
          gum style \
            --foreground 3 \
            --border-foreground 1 \
            --bold \
            --border rounded \
            --align center \
            --width 50 \
            --margin "1 3" \
            --padding "1 4" \
            'Touch ID will not work with sudo until the system configuration has been reapplied.'
        end
      '';
    })

    (mkIf pkgs.stdenv.isDarwin {
      programs.fish.interactiveShellInit = language "fish" ''
        abbr -a netq networkQuality
      '';
    })

    {
      # This is used by so many functions that it's basically essential.
      # I could reference it in each function, but annoyingly that breaks
      # the syntax highlighting that I'm brutally forcing Helix to do.
      home.packages = [ pkgs.gum ];

      programs.fish = {
        enable = true;

        plugins = [
          {
            name = "tide";
            src = inputs.fish-tide;
          }
        ];

        interactiveShellInit = language "fish" ''
          # This is required because I have a custom "command" for Ghostty, which
          # makes it unable to detect my shell.
          if set -q GHOSTTY_RESOURCES_DIR
            source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
            set --prepend fish_complete_path "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_completions.d"
          end

          # This isn't set by default
          set -g fish_color_option blue

          abbr -a cmv "command -v"

          abbr -a n    nix
          abbr -a nxi  nix
          abbr -a nd   "nix develop"
          abbr -a nb   "nix build"
          abbr -a nr   "nix run"
          abbr -a nfl  "nix flake lock"
          abbr -a nfuc "nix flake update --commit-lock-file"
          abbr -a rsf  "rebuild-switch-flake"
          abbr -a rbf  "rebuild-build-flake"

          # Random abbreviations that are easier to type on some layouts, because I hop
          # around a lot.
          abbr -a nv nvim
          abbr -a he hx
          abbr -a pmu permutations

          abbr -a t  tmux
          abbr -a ta "tmux attach; or tmux"
          abbr -a tk "tmux kill-session"
          abbr -a tl "tmux list-sessions"

          abbr -a ts   tailscale
          abbr -a tsd  tailscaled
          abbr -a tf   terraform # not installed globally, used in projects
          abbr -a f    fzf
          abbr -a tree "eza --tree"

          abbr -a co  "cargo"
          abbr -a cob "cargo build"
          abbr -a cor "cargo run"
          abbr -a corr "cargo run --release"
          abbr -a cot "cargo test"
          abbr -a coa "cargo add"
          abbr -a coc "cargo check"

          abbr -a ",a"  "git add"
          abbr -a ",ap" "git add --patch"
          abbr -a ",ad" "git add ."
          abbr -a ",r"  "git restore"
          abbr -a ",rs" "git restore --staged"
          abbr -a ",re" "git reset"
          abbr -a ",c"  "git commit"
          abbr -a ",ca" "git commit --amend"
          abbr -a ",d"  "git diff"
          abbr -a ",dc"  "git diff --cached"
          abbr -a ",m"  "git merge"
          abbr -a ",s"  "git status"
          abbr -a ",p"  "git push"
          abbr -a ",pf" "git push --force-with-lease"
          abbr -a ",pu" "git pull"
          abbr -a ",f"  "git fetch"
          abbr -a ",fu" "git fetch upstream"
          abbr -a ",sw" "git switch"
          abbr -a ",sc" "git switch -c"
          abbr -a ",b"  "git branch"
          abbr -a ",l"  "git log"

          abbr -a gi  "gh issue"
          abbr -a gil "gh issue list"
          abbr -a giv "gh issue view"
          abbr -a gr  "gh pr"
          abbr -a grl "gh pr list"
          abbr -a grv "gh pr view"
          abbr -a grc "gh pr checkout"
          abbr -a gb  "gh browse"
          abbr -a g   "lazygit"

          abbr -a cd     "to" # I want to use my custom `cd` wrapper instead
          abbr -a "-"    "cd -"
          abbr -a ".."   "cd .."
          abbr -a "..."  "cd ../.."
          abbr -a "...." "cd ../../.."
        '';

        functions = {
          # Does mkDefault actually do anything in this situation?
          # I'm not sure! But this seems to work regardless, so I
          # won't change it...
          fish_greeting = mkDefault "";

          # This function is sourced every time the shell starts up
          fish_user_key_bindings = language "fish" ''
            fish_default_key_bindings
            bind \cz 'fg 2>/dev/null; commandline -f repaint'
            bind \ez 'zi; commandline -f repaint'

            # Not sure why but the order of these is broken by default.
            # expand-abbr needs to happen first so the cursor is
            # still over the abbreviation when it tries to expand.
            bind ' ' expand-abbr self-insert
            bind ';' expand-abbr self-insert
            bind '|' expand-abbr self-insert
            bind '&' expand-abbr self-insert
            bind '>' expand-abbr self-insert
            bind '<' expand-abbr self-insert
            bind ')' expand-abbr self-insert
          '';

          # This is the same as the default implementation except that it doesn't
          # print anything if the job has stopped. The original implementation can
          # be found here:
          # https://github.com/fish-shell/fish-shell/blob/8d20bbf/share/functions/fish_job_summary.fish
          fish_job_summary.argumentNames = [
            "job_id"
            "is_foreground"
            "cmd_line"
            "signal_or_end_name"
            "signal_desc"
            "proc_pid"
            "proc_name"
          ];
          fish_job_summary.body = language "fish" ''
            if test "$signal_or_end_name" = SIGINT; and test $is_foreground -eq 1
                return
            end

            set -l max_cmd_len 32
            set cmd_line (string shorten -m$max_cmd_len -- $cmd_line)

            set -l message
            switch $signal_or_end_name
                # case STOPPED
                #     set message (printf ( _ "fish: Job %s, '%s' has stopped\n" ) $job_id $cmd_line)
                case ENDED
                    set message (printf ( _ "fish: Job %s, '%s' has ended\n" ) $job_id $cmd_line)
                case 'SIG*'
                    if test -n "$proc_pid"
                        set message (printf ( _ "fish: Process %s, '%s' from job %s, '%s' terminated by signal %s (%s)\n" ) \
                            $proc_pid $proc_name $job_id $cmd_line $signal_or_end_name $signal_desc)
                    else
                        set message (printf ( _ "fish: Job %s, '%s' terminated by signal %s (%s)\n" ) \
                            $job_id $cmd_line $signal_or_end_name $signal_desc)
                    end
            end

            if test $is_foreground -eq 0; and test $signal_or_end_name != STOPPED
                __fish_echo string join \n -- $message
            else
                string join >&2 \n -- $message
            end
          '';

          # Displays every path in $PATH on new lines.
          # This is similar to
          paths = language "fish" ''
            for path in $PATH
              echo -- $path
            end
          '';

          # Better interactive output than `ls`, and it's on my home row (faster to type).
          e = language "fish" ''
            eza --sort=size --all --header --long --group-directories-first --git -- $argv
          '';

          # Print the root of the git repository, if there is one
          git-root = language "fish" ''
            git rev-parse --git-dir | path dirname
          '';

          # Renames the current working directory
          mvcd = language "fish" ''
            set cwd $PWD
            set newcwd $argv[1]
            cd ..
            mv $cwd $newcwd
            cd $newcwd
            pwd
          '';

          # Sucks items out of the given directories into the destination directory.
          # This is useful for flattening nested directory structures.
          suck = language "fish" ''
            if test (count $argv) -lt 2
              echo 'usage: suck sources... dest' >&2
              return 1
            end

            set dest $argv[-1]
            set dirs $argv[..-2]

            if not test -d $dest
              echo 'error: destination needs to be a directory'
              return 1
            end

            for dir in $dirs
              set keep_dir 0

              for file in $dir/*
                set name (path basename $file)

                if test -e $dest/$name
                  echo "skipping $file"
                  set keep_dir 1
                else
                  mv $file $dest
                end
              end

              if test $keep_dir = 0
                rmdir $dir
              end
            end
          '';

          # Add a suffix to one or more files
          suff = language "fish" ''
            if test (count $argv) -lt 2
              echo 'Requires 2 arguments.  Usage: suff <suffix> <files>...' >&2
              return 1
            end

            set suffix $argv[1]
            set paths $argv[2..]

            for path in $paths
              mv $path $path$suffix
            end
          '';

          # Quick wrapper to make running `nix develop` without any arguments
          # run Fish instead of Bash.
          nix = {
            wraps = "nix";
            description = "Wraps `nix develop` to run fish instead of bash";
            body = language "fish" ''
              if status is-interactive
                and test (count $argv) = 1 -a "$argv[1]" = develop

                # Special case: if there's an initialized .flake directory, use that.
                if test -d .flake -a -f .flake/flake.nix
                  announce nix develop $PWD/.flake --command (status fish-path)
                else
                  announce nix develop --command (status fish-path)
                end

              else
                command nix $argv
              end
            '';
          };

          mkflake = language "fish" ''
            if test -e .flake
              echo "'.flake' exists in this directory"
              return 1
            end

            mkdir .flake
            pushd .flake

            git init

            nix flake init -t my#untracked-flake
            nix flake lock
            git add .

            if gum confirm "Edit the flake?"
              $EDITOR flake.nix
              nix flake lock
            end

            popd
          '';

          # frogmouth is a fantastic markdown reader but it's a bit of a
          # (frog)mouthful to type
          md = alias "frogmouth";

          # Prints the command to the screen, colorized it would be when executed
          # at the command line, then executes the command.
          # This is meant to look like the user is executing the command, while
          # also making it clear it's happening automatically. Useful for functions
          # where it's just some simple commands being run in sequence.
          announce = language "fish" ''
            set colored_command (echo -- "$argv" | fish_indent --ansi)
            echo "$(set_color magenta)~~>$(set_color normal) $colored_command"
            $argv
          '';

          # switch system flake correctly regardless of the operating system
          rebuild-switch-flake = language "fish" ''
            if test (uname) = Darwin
              if string match -iq "*air" (hostname)
                # This isn't the exact name of the host, because I don't own the
                # laptop.
                announce home-manager switch --flake .#robert@macbook-air &| nom
              else
                announce darwin-rebuild switch --flake .# --max-jobs 8 &| nom
              end
            else
              announce sudo nixos-rebuild switch --flake .# &| nom
            end
          '';

          # build system flake correctly regardless of the operating system
          rebuild-build-flake = language "fish" ''
            if test (uname) = Darwin
              if string match -iq "*air" (hostname)
                # This isn't the exact name of the host, because I don't own the
                # laptop.
                announce home-manager build --flake .#robert@macbook-air &| nom
              else
                announce darwin-rebuild build --flake .# --max-jobs 8 &| nom
              end
            else
              announce sudo nixos-rebuild build --flake .# &| nom
            end
          '';

          # `to` wraps `cd`. It's a little bit smarter, but doesn't try to be `z`,
          # because I find `z` can be quite annoying when it doesn't get it right.
          # I try to keep everything pretty flat so it's not super hard to get to
          # where I need to go from $HOME. `to` also combines `mkdir`/`cd`, and
          # knows to take you to the repository root if you run `to` with no directory
          # and you're in a git repository.
          to = {
            wraps = "cd";
            description = "Interactive cd that offers to create directories";
            body = language "fish" ''
              # Some git trickery first. If the function is called with no arguments,
              # typically that means to cd to $HOME, but we can be smarter - if you're
              # in a git repo and not in its root, cd to the root.
              if is_empty $argv
                set git_root (git rev-parse --git-dir 2>/dev/null | path dirname)
                if test $status -eq 0 -a "$git_root" != .
                  cd $git_root
                  return 0
                end
              end

              # Now that's out of the way
              cd $argv
              set cd_status $status
              if test $cd_status -ne 0
                and gum confirm "Create the directory? ($argv[-1])"
                echo "Creating directory"
                command mkdir -p -- $argv[-1]
                builtin cd $argv[-1]
                return 0
              else
                return $cd_status
              end
            '';
          };

          # cd to a temporary directory
          tcd = language "fish" ''
            cd (mktemp -d)
          '';

          # Erase an item from an array by value rather than by index.
          # The normal syntax is `set -e name[index]`, eg. `set -e PATH[2]`
          # but this is bad for interactive use because you need to know
          # the index of the item beforehand. Using the `erase_item` function,
          # you can easily erase an item from an array if you know its value.
          # For each value that isn't found in the array, the return value is
          # incremented by 1.
          #
          #     $ set arr a b c d e
          #     $ erase_item arr c e
          #     $ echo $arr
          #     a b d
          #
          # The function is named with underscores to make it look and feel more like
          # a built-in fish function instead of something I wrote.
          erase_item = language "fish" ''
            set varname $argv[1]
            set retval 0
            # Big O isn't optimal, but executes faster because `contains` is a builtin
            for item in $argv[2..]
              set -l index (contains --index -- $item $$varname)
              if set -q index[1]
                set -e {$varname}[$index]
              else
                set retval (math $retval + 1)
              end
            end
            return $retval
          '';

          is_empty = language "fish" ''
            not count $argv >/dev/null
            return
          '';

          # Where `nix shell` is for creating an ephemeral shell with access to a program, `use`
          # modifies your current environment and allows you to read in a list of installables
          # from a file named .pkgs automatically. This allows it to fill the role of `nix develop`
          # for projects that don't use Nix as their build system, and it allows you to add more
          # tools to your environment without spawning a new subshell.
          # The file, .pkgs, is a line-separated list of packages. It supports blank lines and
          # comments. You don't have to specify `nixpkgs#` if the package is from nixpkgs.
          use = language "fish" ''
            # Stores the list of resolved package names
            set -l packages

            if is_empty $argv
              and path is --type file --perm read .pkgs
              # Quad-escaping the \ because Nix needs to escape it and it needs to be escaped
              # again in fish.
              # This pipeline supports adding comments, leading whitespace, and blank lines.
              set unfixed_packages (cat .pkgs | sed 's/^[[:space:]]*//;/^[[:space:]]*$/d' | grep -v '^#')
            else
              # There's not much of a reason to not also run the same logic on the commandline
              # arguments too, because this allows you to run `use (cat .pkgs)`. Don't know why
              # you'd do that but it makes it more resiliant. Maybe I'll have a use for that one day?
              set unfixed_packages (string join '\\\\n' $argv | sed 's/^[[:space:]]*//;/^[[:space:]]*$/d' | grep -v '^#')
            end

            set active_packages (string split -- ' ' "$USING_PACKAGES")

            for package in $unfixed_packages
              if test "$package" = ""
                continue
              end

              # A hash or colon will be interpreted as a flakeref, everything
              # else is assumed to be nixpkgs
              if string match -qr '#|:' -- $package
                set fixed_name $package
              else
                set fixed_name "nixpkgs#$package"
              end

              if contains -- $fixed_name $active_packages
                continue
              end

              set --append packages $fixed_name
            end

            # No packages to add, so skip all the work and
            if is_empty $packages
              echo "All packages specified are currently being used :)"
              return
            end

            if jobs -q
              echo
              echo -s (set_color red) "Failed to activate packages: " (set_color reset) "shell still has active jobs"
              jobs
              return 1
            end

            echo -s "Checking packages: " (string join ", " (set_color --bold)$packages(set_color reset))

            # Using a fixed path to nix because I have a function wrapper than I don't want
            # to use in this case, and using `command nix` breaks the exec mess below
            set nix (command -v nix)


            # Running a no-op command to test if activating the shell would work. Because
            # an exec is used below, there's only one shot to get it right -- if the exec
            # fails, the user's shell will die, causing their terminal window/pane to close
            if not $nix shell $packages --command true
              echo
              echo -s (set_color red) "Failed to activate packages" (set_color reset)
              return 1
            end

            # Checks are complete, print the packages to make it clear what's being added.
            echo "Success! Activating environment..."
            for pkg in $packages
              echo -s -- "+ " (set_color green) $pkg (set_color reset)
            end

            # Using a semicolon to split the packages because it's guaranteed (?) to never
            # appear in a package specifier. Or at least, it's very unlikely.
            set joined_new_active_packages (string join -- ' ' $packages $USING_PACKAGES)

            # Because the shell isn't being nested, there's no need to increment the SHLVL
            # variable. But holy shit does fish want to increment this variable. This is the
            # only way I've found that works consistenly with various levels.
            # Trying to use `command` seems to break this too. Genuinely no idea why.
            exec \
              env SHLVL=(math "$SHLVL - 1") USING_PACKAGES=$joined_new_active_packages \
                $nix shell $packages \
                  --command (status fish-path)
          '';

          clean-store = language "fish" ''
            announce nix store gc --verbose
            echo
            announce nix store optimise --verbose
          '';

          words = language "fish" ''
            set wordfile $TMPDIR/words.txt
            if test ! -e $wordfile
              echo "Downloading Monkeytype's english10k list" >&2
              curl -s 'https://raw.githubusercontent.com/monkeytypegame/monkeytype/master/frontend/static/languages/english_10k.json' \
              | jq -r '.words[]' > $TMPDIR/words.txt
            end

            if isatty stdin
              set letters $argv
            else
              while read -l line
                set -a letters $line
              end
            end

            if is_empty $letters
              echo "`words` requires at least one pattern to check for as an argument" >&2
            end
            # ripgrep is fast enough that doing this twice is *fine*, not great obviously but
            # there's no point being stingy over a few CPU cycles here. If I really cared I'd
            # do this in Rust instead of making it a hacky shell script. The reason I'm not
            # storing the output and reusing it is because ripgrep detects whether the stdout
            # is a tty and colors the output if it is, and there's no super easy way to get
            # that styling back.
            string join \n -- $letters | rg --file=- $wordfile
            set lines (string join \n -- $letters | rg --file=- $wordfile | count)
            echo "Matches occur in $lines words in english10k"
          '';

          bigrams = language "fish" ''
            set bigramsfile $TMPDIR/bigrams.txt
            if test ! -e $bigramsfile
              echo "Downloading Project Gutenberg bigram data" >&2
              curl -s 'https://gist.githubusercontent.com/lydell/c439049abac2c9226e53/raw/4cfe39fd90d6ad25c4e683b6371009f574e1177f/bigrams.json' \
              | jq -r '.[] | .[0] + " " + (.[1] | tostring)' > $bigramsfile
            end

            if isatty stdin
              set bigrams $argv
            else
              while read -l line
                set -a bigrams $line
              end
            end

            if is_empty $bigrams
              echo "`bigrams` requires at least one pattern to check for as an argument" >&2
            end
            string join \n -- $bigrams | rg --file=- $bigramsfile
          '';

          # Run the program using a different executable on your $PATH instead of the
          # first one the shell finds
          pick = language "fish" ''
            if is_empty $argv
              return 1
            end
            set paths (path filter -fx $PATH/$argv[1])
            set total (count $paths)
            if test $total = 0
              # Allow it to get handled by the user's command not found handler
              $argv
              return 1
            else
              set picked (printf "%s\n" $paths | fzf)
              if test $status != 0
                return 1
              end
              $picked $argv[2..]
            end
          '';

          # once again, if I cared about this being fast, I'd just use Rust
          permutations =
            let
              # pkgs has a trivial builder I can use for this if I need it again
              pythonFunction = string: ''
                ${pkgs.python3}/bin/python -c '
                ${string}
                ' $argv
              '';
            in
            pythonFunction (
              language "python" ''
                import sys

                if len(sys.argv) < 2:
                  sys.exit(1)

                from functools import reduce
                from itertools import permutations
                from operator import add

                if len(sys.argv) > 2:
                  items = sys.argv[1:]
                else:
                  items = sys.argv[1]

                for a in permutations(items):
                  print(reduce(add, a))
              ''
            );
        };
      };
    }
  ]);
}
