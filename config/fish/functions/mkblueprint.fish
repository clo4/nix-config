function mkblueprint
    nix flake init -t blueprint
    direnv allow
end
