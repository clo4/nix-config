if status is-interactive
    # Tide hasn't been set up yet but it is installed, so this must be a first-time setup.
    # This isn't critical to be in config.fish, but it's good to know that all other configuration
    # has already been applied before any setup is done.
    if not set -q tide_left_prompt_items; and type -q tide
        tide configure --auto --style='Lean' --prompt_colors='16 colors' --show_time='No' --lean_prompt_height='One line' --prompt_spacing='Compact' --icons='Few icons' --transient='No'

        set -g __setup__clear_screen_prompt_count 0
        function __setup__clear_screen --on-event fish_prompt
            if test "$__setup__clear_screen_prompt_count" = 0
                # Clearing the screen here gets rid of the greeting if it was displayed
                clear
                echo "          Tide has been set up."
                echo "          Press enter to begin."
                set -e __setup__clear_screen_prompt_count
            else
                clear
                functions -e __setup__clear_screen
                fish_greeting
            end
        end
    end
end
