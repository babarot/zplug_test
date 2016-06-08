for fp in "$ZPLUG_ROOT/base"/*/*.zsh
do
    parent="${fp:h:t}"
    child="${fp:t:r}"
    test_file="$ZPLUG_ROOT/test/base/$parent/$child.t"

    # Check if already exists
    if [[ -f $test_file ]]; then
        echo -en "$test_file: is already exists. Overwrite? y/N: "
        read -q ans && echo
        if [[ ! ${(L)ans} =~ ^y(es)?$ ]]; then
            continue
        fi
    fi

    # Update
    rm -f "$test_file"
    cat "$fp" \
        | grep "^__zplug::$parent::$child" \
        | awk '
    {
        gsub(/\(\)/, "")
        gsub(/ {/, "")
        print "T_SUB \"" $0 "\" (("
        print "  # skip"
        print "))"
    }
    ' >> "$test_file"
done
