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

        if (( $ret != 0  )); then
            return $ret
        fi
    done
}

__zplug::core::options::short()
{
    __zplug::io::print::f \
        --die \
        --zplug \
        "$arg: not yet available\n"
    return 1
}

__zplug::core::options::long()
{
    local arg="${1:?}"; shift
    local opt="${arg#--}"

    if [[ -f $ZPLUG_ROOT/autoload/options/__${opt}__ ]]; then
        __zplug::core::core::run_interfaces \
            "$opt" \
            "$argv[@]"
        return $status
    else
        __zplug::io::print::f \
            --die \
            --zplug \
            "$arg: no such option\n"
        return 1
    fi
}
