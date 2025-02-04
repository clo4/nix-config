function poke
for arg in $argv
mkdir -p (path dirname $arg); and touch $arg
end
end
