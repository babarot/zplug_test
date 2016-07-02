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
    local -i lines=0
    local    w pre_format post_format format
    local -a pre_formats post_formats
    local -a formats texts
    local    arg text
    local -i fd=1
    local \
        is_raw=false \
        is_end=false \
        is_multi=false
    local \
        is_end_specified=false \
        is_per_specified=false

    if (( $argv[(I)--] )); then
        is_end_specified=true
    fi
    if (( $argv[(I)*%*] )); then
        is_per_specified=true
    fi

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
                ;;
            --multi)
                is_multi=true
                ;;
            --zplug)
                pre_formats+=( "[zplug]" )
                ;;
            --warn)
                pre_formats+=( "$fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color:" )
                ;;
            --error)
                pre_formats+=( "$fg[red]ERROR$reset_color:" )
                ;;
            --)
                is_end=true
                ;;
            --* | -*)
                __zplug::io::print::die "$arg: no such option\n"
                ;;
            "")
                ;;
            *)
                # Check if the double hyphens exist in args
                if $is_end_specified; then
                    # Divide
                    if $is_end; then
                        texts+=( "$arg" )
                    else
                        post_formats+=( "$arg" )
                    fi
                else
                    texts+=( "$arg" )
                fi
                ;;
        esac
        shift
    done

    # Change the output destination by the value of $fd
    {
        echo "${pre_formats[*]}" \
            | __zplug::utils::shell::unansi \
            | read pre_format
        repeat $#pre_format; do w="$w "; done

        if $is_end_specified; then
            printf "${post_formats[*]}" \
                | grep -c "" \
                | read lines
            for (( i = 1; i <= $lines; i++ ))
            do
                if ! $is_multi && (( $i > 1 )); then
                    pre_formats=( "$w" )
                fi
                formats[$i]="${pre_formats[*]} $post_formats[$i]"
            done
            command printf -- "${(j::)formats[@]}" "${texts[@]}"
        elif $is_per_specified; then
            command printf -- "${pre_formats[*]} ${texts[@]}"
        else
            format="${pre_formats[*]}"
            for (( i = 1; i <= $#texts; i++ ))
            do
                if ! $is_multi && (( $i > 1 )); then
                    format="$w"
                fi
                formats[$i]="${format:+$format }$post_formats[$i]"
                command printf -- "$formats[$i]$texts[$i]"
            done
        fi
    } >&$fd
}

source base/utils/shell.zsh
__zplug::io::print::f \
    --zplug \
    --multi \
    "%s\n" "%s\n" \
    -- \
    abc abc
__zplug::io::print::f \
    --zplug \
    "%s\n" "%s\n" \
    -- \
    abc abc
__zplug::io::print::f \
    --zplug \
    "%s\n%s\n" \
    abc abc
__zplug::io::print::f \
    --zplug \
    --multi \
    "abc\n" "abc\n"
__zplug::io::print::f \
    --zplug \
    "abc\n" "abc\n"
