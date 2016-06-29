__zplug::core::arguments::exec()
{
    local arg="${1:?}" cmd

    reply=()
    __zplug::core::commands::user_defined

    # User-defined command
    if [[ -n ${(M)reply[@]:#$arg} ]]; then
        eval "$commands[zplug-$arg]"
        return $status
    fi

    __zplug::core::arguments::auto_correct "$arg" \
        | read cmd && \
        zplug "$cmd" ${2:+"$argv[2,-1]"}
}

__zplug::core::arguments::auto_correct()
{
    local    arg="${1:?}"
    local -i ret=0
    local -a cmds reply_cmds

    reply_cmds=()
    __zplug::core::commands::user_defined
    reply_cmds+=( "${reply[@]}" )
    __zplug::core::commands::get
    reply_cmds+=( "${reply[@]}" )

    cmds=(
    ${(@f)"$(awk \
        -f "$_ZPLUG_AWKPATH/fuzzy.awk" \
        -v search_string="$arg" \
        <<<"${(F)reply_cmds:gs:_:}"
    )":-}
    )

    case $#cmds in
        0)
            __zplug::io::print::f \
                --die \
                --zplug \
                "$arg: no such command\n"
            ret=1
            ;;
        1)
            __zplug::io::print::f \
                --die \
                --zplug \
                --warn \
                "You called a zplug command named '%s', which does not exist.\n" \
                "$arg"
            __zplug::io::print::f \
                --die \
                --zplug \
                --warn \
                "Continuing under the assumption that you meant '$fg[green]%s$reset_color'.\n" \
                "$cmds[1]"

            __zplug::io::print::put "$cmds[1]\n"
            ;;
        *)
            __zplug::io::print::f \
                --die \
                --zplug \
                --warn \
                "'%s' is not a zplug command. see 'zplug --help'.\n" \
                "$arg"
            __zplug::io::print::die \
                "               Did you mean one of these?\n"
            __zplug::io::print::die \
                "               %s\n" "${cmds[@]}"
            ret=1
            ;;
    esac

    return $ret
}

__zplug::core::arguments::none()
{
    # TODO
    :
}
