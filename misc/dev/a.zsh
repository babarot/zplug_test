for fp in autoload/{commands,options,tags}/__*__
do
    dir="${fp:h}"
    file="${fp:t}"
    name="${file:gs:_:}"
    touch "test/$dir/$name.t"
done
