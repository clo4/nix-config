function paths
    set --append --local argv PATH
    set --local --path paths $$argv[1]
    for p in $paths
        echo $p
    end
end
