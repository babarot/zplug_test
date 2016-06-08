__zplug::core::add::to_zplugs()
{
    local    name
    local    tag key val
    local -a tags
    local -a re_tags

    tags=( ${(s/, /)@:gs/,  */, } )
    name="${tags[1]}"
    tags[1]=()

    # DEPRECATED: pipe
    if [[ -p /dev/stdin ]]; then
        __zplug::core::v1::pipe
        return $status
    fi

    # In the case of "from:local", it accepts multiple slashes
    if [[ ! $name =~ [~$/] ]] && [[ ! $name =~ "^[^/]+/[^/]+$" ]]; then
        __zplug::io::print::die \
            "[zplug] ERROR: ${(qq)name} is invalid package name\n"
        return 1
    fi

    if __zplug::base::base::is_cli; then
        if __zplug::base::base::zpluged "$name"; then
            __zplug::io::print::die "[zplug] $name: already managed\n"
            return 1
        else
            # Add to the external file
            __zplug::io::file::append \
                "zplug ${(qqq)name}${tags[@]:+", ${(j:, :)${(q)tags[@]}}"}"
        fi
    fi

    name="$(__zplug::core::add::proc_at-sign "$name")"

    # Reconstruct the tag information
    for tag in "${tags[@]}"
    do
        key=${${(s.:.)tag}[1]}
        val=${${(s.:.)tag}[2]}

        if (( $+_zplug_tags[$key] )); then
            case $key in
                "of" | "file" | "commit" | "do")
                    __zplug::core::v1::tags "$key"
                    ;;
                "from")
                    __zplug::sources::call::this "$val"
                    ;;
            esac

            # Reconstruct
            re_tags+=("$key:$val")
        else
            __zplug::io::print::die \
                "[zplug] $tag: $key is invalid tag name\n"
            return 1
        fi
    done

    __zplug::sources::call::default

    # Add to zplugs
    zplugs+=("$name" "${(j:, :)re_tags[@]:-}")
}

__zplug::core::add::proc_at-sign()
{
    local    name="${1:?}" key
    local -i max=0

    if __zplug::base::base::zpluged; then
        for key in "${(k)zplugs[@]}"
        do
            if [[ $key =~ ^$name@*$ ]] && (( $max < $#key )); then
                max=$#key
                name="${key}@"
            fi
        done
    fi

    echo "$name"
}
