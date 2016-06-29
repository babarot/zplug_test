__zplug::io::print::put()
{
    command printf -- "$@"
}

__zplug::io::print::die()
{
    command printf -- "$@" >&2
}

__zplug::io::print::f()
{
    local -a formats texts
    local    arg text
    local -i fd=1
    local \
        is_raw=false

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --put | -1)
                fd=1
                ;;
            --die | -2)
                fd=2
                ;;
            --raw)
                is_raw=true
                ;;
            --zplug)
                formats+=( "[zplug]" )
                ;;
            --warn)
                formats+=( "$fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color:" )
                ;;
            --error)
                formats+=( "$fg[red]ERROR$reset_color:" )
                ;;
            --)
                if $is_raw; then
                    texts+=( "\n" )
                fi
                ;;
            --* | -*)
                __zplug::io::print::die "$arg: no such option\n"
                ;;
            "")
                ;;
            *)
                texts+=( "$arg" )
                ;;
        esac
        shift
    done

    format="${formats[*]}"

    if $is_raw; then
        for text in "$texts[@]"
        do
            command printf -- "$format $text"
        done >&$fd
    else
        command printf -- "${texts[@]}" \
            | sed 's/^/'"$format "'/g'
    fi
}
