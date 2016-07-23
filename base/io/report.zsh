__zplug::io::report::write()
{
    cat <&0 >>|"$ZPLUG_ERROR_LOG"
}

__zplug::io::report::reporter()
{
    local -a header data

    # Assume the stdin that should be discarded to /dev/null
    data=( ${(@f)"$(<&0)"} )

    header=()
    header+=( "[$(date +"%Y/%m/%d %T")]" )
    if [[ -n $funcstack[-1] ]]; then
        header+=( "$funcstack[-1]" )
    fi
    header+=( "(${PWD/$HOME/~})" )

    # Log report
    print -l "${header[*]}: ${^data[@]}"
}

__zplug::io::report::save()
{
    __zplug::io::report::reporter \
        | __zplug::io::report::write
}
