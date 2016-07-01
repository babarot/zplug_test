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
    local -a pre_formats post_formats
    local -a formats texts
    local    arg text
    local -i fd=1
    local \
        is_raw=false \
        is_end=false \
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
                is_raw=true
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
                if $is_end_specified; then
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
        if $is_end_specified; then
            local -i lines=0
            printf "${post_formats[*]}" | grep -c "" | read lines
            if (( $lines > 1 )); then
                perl -pe 's/\e\[?.*?[\@-~]//g' <<<"${pre_formats[*]}" | read pre_format
                repeat $#pre_format; do w="$w "; done
            fi
            for ((i = 1; i <= $lines; i++))
            do
                if (( $i > 1 )); then
                    pre_formats=( "$w" )
                fi
                formats[$i]="${pre_formats[*]} $post_formats[$i]"
            done
            command printf -- "${(j::)formats[@]}" "${texts[@]}"
        else
            if $is_per_specified; then
                command printf -- "${pre_formats[*]} ${texts[@]}"
            else
                format="${pre_formats[*]}"
                for text in "$texts[@]"
                do
                    command printf -- "$format $text"
                done
            fi
        fi
    } >&$fd
}

__zplug::io::print::f --zplug --warn "%s\n" "%s\n" -- abc abc
#__zplug::io::print::f --zplug --warn "%s\n%s\n" abc abc
#__zplug::io::print::f --zplug --warn "abc\n" "abc\n"
