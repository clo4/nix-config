function mkblueprint
    nix flake init -t blueprint
    git init
    git add .
    direnv allow
end
