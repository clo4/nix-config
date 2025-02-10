function mkblueprint
    nix flake init -t blueprint
    nix flake update
    git init
    git add .
    direnv allow
end
