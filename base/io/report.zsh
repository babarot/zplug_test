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
    local -a results

    # Assume the stdin that should be discarded to /dev/null
    results=( ${(@f)"$(<&0)"} )
    if (( $#results == 0 )); then
        return 1
    fi

    # Spit out to JSON
    printf '{'
    printf '"pid": %d,' "$$"
    printf '"level": %d,' "$SHLVL"
    printf '"date": "%s",' "$(date +"%Y/%m/%d %T")"
    printf '"directory": "%s",' "$PWD"
    printf '"result": %s,' "${(qqq)results[*]}"
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
    printf "}}\n"
}

__zplug::io::report::save()
{
    __zplug::io::report::with_json \
        | __zplug::io::report::write
}
