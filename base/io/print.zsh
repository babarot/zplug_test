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

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --zplug)
                formats+=( "[zplug] " )
                ;;
            --warn)
                formats+=( "$fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color: " )
                ;;
            --error)
                formats+=( "$fg[red]ERROR$reset_color: " )
                ;;
            --)
                texts+=( "\n" )
                ;;
            *)
                texts+=( "$arg" )
                ;;
        esac
        shift
    done

    texts=( "$formats[@]" "$texts[@]" )

    for text in "$texts[@]"
    do
        command printf -- "$text"
    done
}
