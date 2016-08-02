__zplug::io::report::write()
{
    cat <&0 >>|"$ZPLUG_ERROR_LOG"
}

__zplug::io::report::with_json()
{
    # Variables for error report
    # - $funcfiletrace[@]
    # - $funcsourcetrace[@]
    # - $funcstack[@]
    # - $functrace[@]

    local -i i
    local -a message
    local    date

    # Assume the stdin that should be discarded to /dev/null
    message=( ${(@f)"$(<&0)"} )
    if (( $#message == 0 )); then
        return 1
    fi

    # https://tools.ietf.org/html/rfc3339#section-5.6
    date="$(date +%FT%T%z | sed -E 's/(.*)([0-9][0-9])([0-9][0-9])/\1\2:\3/')"

    # Spit out to JSON
    printf '{'
    printf '"pid": %d,' "$$"
    printf '"level": %d,' "$SHLVL"
    printf '"date": "%s",' "$date"
    printf '"dir": "%s",' "$PWD"
    printf '"message": %s,' "${(qqq)message[*]}"
    printf '"trace": {'
    for ((i = 1; i < $#functrace; i++))
    do
        # With comma
        printf '"%s": "%s",' \
            "$functrace[$i]" \
            "$funcstack[$i]"
    done
    # Without comma
    printf '"%s": "%s"' \
        "$functrace[$#functrace]" \
        "$funcstack[$#funcstack]"
    printf "}"
    printf "}\n"
}

__zplug::io::report::save()
{
    __zplug::io::report::with_json \
        | __zplug::io::report::write
}
