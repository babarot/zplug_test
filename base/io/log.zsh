# https://tools.ietf.org/html/rfc5424
#
# Numerical         Severity
#    Code
#
#      0       Emergency: system is unusable
#      1       Alert: action must be taken immediately
#      2       Critical: critical conditions
#      3       Error: error conditions
#      4       Warning: warning conditions
#      5       Notice: normal but significant condition
#      6       Informational: informational messages
#      7       Debug: debug-level messages

typeset -gx -A _zplug_log_level
_zplug_log_level=(
''      '0:Emergency:system is unusable'
''      '1:Alert:action must be taken immediately'
''      '2:Critical:critical conditions'
'ERROR' '3:Error:error conditions'
'WARN'  '4:Warning:warning conditions'
''      '5:Notice:normal but significant condition'
'INFO'  '6:Informational:informational messages'
''      '7:Debug:debug-level messages'
)

__zplug::io::log::with_json()
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
    printf '"shlvl": %d,' "$SHLVL"
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

__zplug::io::log::report()
{
    :
}

__zplug::io::log::save()
{
    __zplug::io::log::with_json \
        | >>|"$ZPLUG_ERROR_LOG"
}
