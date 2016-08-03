__zplug::core::options::get()
{
    __zplug::core::core::get_interfaces \
        "options" \
        "$argv[@]"
}

__zplug::core::options::parse()
{
    local    arg
    local -i ret=0

    while (( $# > 0 ))
    do
        arg="${1:?}"
        case "$arg" in
            "--")
                # TODO
                ;;

            "-")
                # TODO
                ;;

            --*)
                __zplug::core::options::long \
                    "$arg" \
                    ${2:+"$argv[2,-1]"}
                ret=$status
                ;;

            -*)
                __zplug::core::options::short \
                    "$arg" \
                    ${2:+"$argv[2,-1]"}
                ret=$status
                ;;

            *)
                # Impossible condition
                ;;
        esac
        shift
    done

    return $ret
}

__zplug::core::options::short()
{
    __zplug::io::print::f \
        --die \
        --zplug \
        "$arg: no such option\n"
    return 1
}

__zplug::core::options::long()
{
    local    key value
    local -a args opts

    __zplug::utils::shell::getopts "$argv[@]" \
        | while read key value; \
    do
        case "$key" in
            _)
                args+=( "$value" )
                ;;
            *)
                opts+=( "$key" )
                args+=( "$value" )
                ;;
        esac
    done

    opt="$opts[1]"

    if [[ -f $ZPLUG_ROOT/autoload/options/__${opt}__ ]]; then
        __zplug::core::core::run_interfaces \
            "$opt" \
            "$args[@]"
        return $status
    else
        __zplug::io::print::f \
            --die \
            --zplug \
            "$argv[1]: no such option\n"
        return 1
    fi
}
