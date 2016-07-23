__zplug::io::report::write()
{
    cat <&0 >>|"$ZPLUG_ERROR_LOG"
}

__zplug::io::report::reporter()
{
    local -a header results
    local    w=""
    local -i i=0

    # Assume the stdin that should be discarded to /dev/null
    results=( ${(@f)"$(<&0)"} )

    header=()
    header+=( "[$(date +"%Y/%m/%d %T")]" )
    header+=( "${PWD/$HOME/~}" )

    # Make spaces
    for ((; i < ${#${header[*]}}; i++))
    do
        w="$w "
    done

    # Spit out to JSON
    printf '{'
    printf '"date": "%s",' "$(date +"%Y/%m/%d %T")"
    printf '"directory": "%s",' "$PWD"
    printf '"result": "%s",' "${results[*]}"
    printf '"trace": {'
    for ((i = 1; i < $#functrace; i++))
    do
        # Comma
        printf "\"%s\": \"%s\"," \
            "$functrace[$i]" \
            "$funcstack[$i]"
    done
    printf "\"%s\": \"%s\"" "$functrace[$#functrace]" "$funcstack[$#funcstack]"
    printf "}}\n"

    # $funcfiletrace[@]
    # $funcsourcetrace[@]
    # $funcstack[@]
    # $functrace[@]
}

__zplug::io::report::save()
{
    __zplug::io::report::reporter \
        | __zplug::io::report::write
}
