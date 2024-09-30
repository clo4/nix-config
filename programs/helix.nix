{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.programs.helix;
  language = name: text: text;
  myTheme = "gruvbox_clo4";
in
{
  options = {
    my.programs.helix.enable = mkEnableOption "my helix configuration";
  };

  config = mkIf cfg.enable {
    # Might have to refactor this into a module or upstream it if I add more queries!
    xdg.configFile."helix/runtime/queries/nix/injections.scm".text =
      let
        # Helix will override whatever the builtin injection query is with your own
        # if you don't copy it and append your query to it.
        originalNixInjections = builtins.readFile (inputs.helix + "/runtime/queries/nix/injections.scm");
      in
      language "scheme" ''
        ; This is a simple query that allows you to define a function called "language" and
        ; highlight as whatever its first argument is. `language = name: str: str;`
        ((apply_expression
           function: (apply_expression function: (_) @_func
             argument: (string_expression (string_fragment) @injection.language))
           argument: (indented_string_expression (string_fragment) @injection.content))
         (#eq? @_func "language")
         (#set! injection.language))

        ${originalNixInjections}
      '';

    xdg.configFile."helix/runtime/queries/go/injections.scm".text =
      let
        originalGoInjections = builtins.readFile (inputs.helix + "/runtime/queries/go/injections.scm");
      in
      language "scheme" ''
        ; Inject SQL as the first argument to the standard library's SQL methods
        ; Query | QueryRow | Exec
        ((call_expression
          function: (selector_expression
            operand: (_)
            field: (field_identifier) @_querier (#match? @_querier "^Query(Row)?|Exec$"))
          arguments: (argument_list
            [(interpreted_string_literal) (raw_string_literal)] @injection.content))
          (#set! injection.language "sql"))

        ; Inject SQL as the second argument to all the different SQL query methods
        ; ( Query | QueryRow | QueryContext | QueryRowContext | Exec | ExecContext )
        ; This supports the style that PGX uses where there is implicitly a context
        ; argument for each function.
        ((call_expression
          function: (selector_expression
            operand: (_)
            field: (field_identifier) @_querier (#match? @_querier "^(Query(Row)?|Exec)(Context)?$"))
          arguments: (argument_list
            (_)
            [(interpreted_string_literal) (raw_string_literal)] @injection.content))
          (#set! injection.language "sql"))

        ${originalGoInjections}
      '';

    programs.helix = {
      enable = true;
      defaultEditor = true;
      package = inputs.helix.packages.${pkgs.stdenv.system}.default;

      # # nu syntax has been updated a fair bit since the last update to the default language file
      # package = inputs.helix.packages.${pkgs.stdenv.system}.default.override {
      #   grammarOverlays = [
      #     (final: prev: {
      #       nu = prev.nu.overrideAttrs {
      #         rev = "2d0dd587dbfc3363d2af4e4141833e718647a67e";
      #       };
      #     })
      #   ];
      # };

      settings = {
        theme = "gruvbox";
        # theme = myTheme;

        editor = {
          # Override because every terminal I use supports true color, but
          # sometimes helix fails to detect it over ssh, tmux, etc.
          true-color = true;
          color-modes = true;
          line-number = "relative";
          idle-timeout = 0;
          completion-trigger-len = 1;
          bufferline = "multiple";
        };

        editor.statusline = {
          right = [
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-encoding"
          ];
        };

        editor.cursor-shape = {
          insert = "bar";
          select = "underline";
          normal = "block";
        };

        editor.indent-guides = {
          render = true;
          character = "▏";
          skip-levels = 1;
        };

        editor.whitespace = {
          render.newline = "all";
          characters.newline = "↵";
        };

        editor.lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        editor.inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "hint";
        };

        keys.normal = {
          # This goes against the Helix way of selection->action but it's a
          # common enough thing to warrant making it its own keybind.
          # D = ["goto_first_nonwhitespace" "extend_to_line_end" "change_selection"];

          # Mode switching always happens at the end of the list of commands, so
          # the order that these are in doesn't matter because collapsing the selection
          # will always happen first.
          a = [
            "append_mode"
            "collapse_selection"
          ];
          i = [
            "insert_mode"
            "collapse_selection"
          ];

          # Mnemonic: control hints
          C-h = ":toggle-option lsp.display-inlay-hints";

          # By default, Helix tries to leave the cursor where it was when scrolling
          C-d = [
            "half_page_down"
            "goto_window_center"
          ];
          C-u = [
            "half_page_up"
            "goto_window_center"
          ];

          # Searching for a selection probably shouldn't have whitespace included.
          # Makes sense to keep the default keybind in select mode though?
          "*" = [
            "trim_selections"
            "search_selection"
            "select_mode"
          ];
        };

        keys.normal.C-q = ":quit-all";
        keys.normal.C-w = ":quit";
        keys.normal.space.d = "vsplit";
        keys.select.space.d = "vsplit";
        keys.normal.space.D = "hsplit";
        keys.select.space.D = "hsplit";

        keys.normal.C-r = ":reload";
        keys.normal.C-R = ":reload-all";
        keys.normal.space.u = ":reset-diff-change";

        keys.normal.D = "goto_word";
        keys.select.D = "extend_to_word";
        # keys.normal.V = "add_selection_on_word";
        # keys.select.V = "add_selection_on_word";

        keys.normal.S-left = "jump_view_left";
        keys.select.S-left = "jump_view_left";
        keys.normal.S-right = "jump_view_right";
        keys.select.S-right = "jump_view_right";
        keys.normal.S-up = "jump_view_up";
        keys.select.S-up = "jump_view_up";
        keys.normal.S-down = "jump_view_down";
        keys.select.S-down = "jump_view_down";

        # lots of repetition. if only there was a configuration language with functions that
        # compiled to the desired end format. oh well
        keys.normal."`" = {
          c = [
            "trim_selections"
            ":pipe ccase --to camel"
          ];
          C = [
            "trim_selections"
            ":pipe ccase --to uppercamel"
          ];
          s = [
            "trim_selections"
            ":pipe ccase --to snake"
          ];
          S = [
            "trim_selections"
            ":pipe ccase --to screamingsnake"
          ];
          k = [
            "trim_selections"
            ":pipe ccase --to kebab"
          ];
          K = [
            "trim_selections"
            ":pipe ccase --to upperkebab"
          ];
          t = [
            "trim_selections"
            ":pipe ccase --to title"
          ];
          r = [
            "trim_selections"
            ":pipe ccase --to pseudorandom"
          ];
        };

        keys.select."`" = {
          c = [
            "trim_selections"
            ":pipe ccase --to camel"
          ];
          C = [
            "trim_selections"
            ":pipe ccase --to uppercamel"
          ];
          s = [
            "trim_selections"
            ":pipe ccase --to snake"
          ];
          S = [
            "trim_selections"
            ":pipe ccase --to screamingsnake"
          ];
          k = [
            "trim_selections"
            ":pipe ccase --to kebab"
          ];
          K = [
            "trim_selections"
            ":pipe ccase --to upperkebab"
          ];
          t = [
            "trim_selections"
            ":pipe ccase --to title"
          ];
          r = [
            "trim_selections"
            ":pipe ccase --to pseudorandom"
          ];
        };

        # These are unbound by default, probably because there's not really a good reason
        # to use them. But because I use the arrow keys on the home row of my keyboard (hjkl
        # are in other locations because I use an alternate keyboard layout) I need to
        # add the bindings for them.
        keys.normal.g = {
          left = "goto_line_start";
          right = "goto_line_end";
          up = "move_line_up";
          down = "move_line_down";
        };
        keys.select.g = {
          left = "goto_line_start";
          right = "goto_line_end";
          up = "move_line_up";
          down = "move_line_down";
        };

        keys.normal.Z =
          let
            repeat = count: thing: if count < 2 then [ thing ] else [ thing ] ++ repeat (count - 1) thing;
          in
          {
            C-d = [
              "half_page_down"
              "goto_window_center"
            ];
            C-u = [
              "half_page_up"
              "goto_window_center"
            ];

            d = "scroll_down";
            u = "scroll_up";
            e = "scroll_down";
            y = "scroll_up";

            # upper case should move more than one line but less than a half page
            J = repeat 5 "scroll_down";
            K = repeat 5 "scroll_up";
            D = repeat 5 "scroll_down";
            U = repeat 5 "scroll_up";
            E = repeat 5 "scroll_down";
            Y = repeat 5 "scroll_up";
          };

        keys.normal.space.w = {
          V = [
            "vsplit_new"
            "file_picker"
          ];
          S = [
            "hsplit_new"
            "file_picker"
          ];
        };

        keys.select = {
          # Mode switching always happens at the end of the list of commands, so
          # the order that these are in doesn't matter because collapsing the selection
          # will always happen first.
          a = [
            "append_mode"
            "collapse_selection"
          ];
          i = [
            "insert_mode"
            "collapse_selection"
          ];

          C-h = ":toggle-option lsp.display-inlay-hints";

          C-d = [
            "half_page_down"
            "goto_window_center"
          ];
          C-u = [
            "half_page_up"
            "goto_window_center"
          ];

          # When I collapse a selection in select mode, the next thing I do
          # is *always* enter normal mode.
          ";" = [
            "collapse_selection"
            "normal_mode"
          ];
        };

        keys.insert = {
          C-h = ":toggle-option lsp.display-inlay-hints";

          # This is a pretty standard shortcut in most editors
          C-space = "completion";
        };
      };

      themes.${myTheme} = {
        inherits = "gruvbox";

        comment.fg = "gray1";

        "ui.virtual.jump-label" = {
          fg = "purple0";
          bg = "bg-1";
          modifiers = [ "bold" ];
        };

        palette.bg-1 = "#141414";
      };

      languages.language-server = {
        deno = {
          command = "deno";
          args = [ "lsp" ];
          config = {
            enable = true;
            unstable = true;
            lint = true;
          };
        };

        vtsls = {
          command = "vtsls";
          args = [ "--stdio" ];
        };

        svelteserver.command = "svelteserver";

        tailwindcss = {
          command = "tailwindcss-language-server";
          language-id = "tailwindcss";
          args = [ "--stdio" ];
          config = { };
        };

        rust-analyzer = {
          command = "rust-analyzer";
          config.check.command = "clippy";
        };

        ltex-ls.command = "ltex-ls";
      };

      languages.language = [
        {
          name = "go";
          auto-format = true;
          formatter = {
            command = "goimports";
          };
        }
        {
          name = "typescript";
          language-servers = [ "vtsls" ];
        }
        {
          name = "nix";
          language-servers = [ "nil" ];
          auto-format = true;
          formatter = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            args = [ "-" ];
          };
        }
        {
          name = "fish";
          auto-format = true;
          formatter.command = "${pkgs.fish}/bin/fish_indent";
        }
        {
          name = "markdown";
          language-servers = [ "ltex-ls" ];
          auto-format = false;
          formatter = {
            command = "deno";
            args = [
              "--ext"
              "md"
              "-"
            ];
          };
        }
        {
          name = "git-commit";
          language-servers = [ "ltex-ls" ];
        }
      ];
    };
  };
}
