__zplug::utils::shell::remove_deadlinks()
{
    local link

    for link in "$@"
    do
        if [[ -L $link ]] && [[ ! -e $link ]]; then
            rm -f "$link"
        fi
    done
}

__zplug::utils::shell::search_commands()
{
    local -a args
    local    arg element cmd_name
    local    is_verbose=true

    while (( $# > 0 ))
    do
        arg="$1"
        case $arg in
            --verbose)
                is_verbose=true
                ;;
            --silent)
                is_verbose=false
                ;;
            -*|--*)
                return 1
                ;;
            *)
                args=+( "$arg" )
                ;;
        esac
        shift
    done

    for arg in "${args[@]}"
    do
        for element in "${(s.:.)arg}"
        do
            # Extract the first argument sparated by a space
            cmd_name="${element%% *}"

            # Check if cmd_name is available
            if (( $+commands[$cmd_name] )); then
                if $is_verbose; then
                    echo "$cmd_name"
                fi
                return 0
            else
                continue
            fi
        done
    done

    return 1
}

__zplug::utils::shell::glob2regexp()
{
    local -i i=0
    local    glob="${1:?}" char

    printf "^"
    for ((; i < $#glob; i++))
    do
        char="${glob:$i:1}"
        case "$char" in
            \*)
                printf '.*'
                ;;
            .)
                printf '\.'
                ;;
            "{")
                printf '('
                ;;
            "}")
                printf ')'
                ;;
            ,)
                printf '|'
                ;;
            "?")
                printf '.'
                ;;
            \\)
                printf '\\\\'
                ;;
            *)
                printf "$char"
                ;;
        esac
    done
    printf "$\n"
}

__zplug::utils::shell::sudo()
{
    local pw="$ZPLUG_SUDO_PASSWORD"

    if [[ -z $pw ]]; then
        __zplug::print::die \
            "ZPLUG_SUDO_PASSWORD: is an invalid value\n"
        return 1
    fi

    sudo -k
    echo "$pw" \
        | sudo -S -p '' "$argv[@]"
}

__zplug::utils::shell::unansi()
{
    perl -pe 's/\e\[?.*?[\@-~]//g'
}
