__zplug::core::tags::get()
{
    local    tag tag_name tag_path
    local -A tags

    for tag in "$ZPLUG_ROOT/autoload/tags"/__*__
    do
        tag_name="${tag:t:gs:_:}"
        tag_path="$tag"
        tags[$tag_name]="$tag_path"
    done

    reply=( "${(kv)tags[@]}" )
}

__zplug::core::tags::parse()
{
    local    arg="${1:?}" tag
    local -A tags
    local -a pairs

    __zplug::core::tags::get
    tags=( "${reply[@]}" )

    pairs=("name" "$arg")

    for tag in "${(k)tags[@]}"
    do
        pairs+=("$tag" "$(${tags[$tag]:t} "$arg")")
    done

    reply=( "${pairs[@]}" )
}
