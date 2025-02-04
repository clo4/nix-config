function abbred
    set abbrfile ~/.config/fish/conf.d/abbreviations.fish
    pushd ~/.config/fish
    $EDITOR $abbrfile
    set editor_status $status
    popd
    if test $editor_status -gt 0
        echo "$EDITOR exited with a non-zero status code, not executing abbreviations"
        return 1
    end
    echo "removing and reapplying abbreviations"
    abbr --erase (abbr --list)
    # This file can be sourced unconditionally because it only contains abbreviations,
    # which are idempotent if executed with the same name.
    source $abbrfile
end
