__zplug::job::hook::service()
{
    local    repo="${1:?}" hook="${2:?}"
    local -A tags

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # There is no $hook file in /autoload/tags directory
    if (( ! $+tags[$hook] )); then
        __zplug::io::print::die \
            "$hook: this hook tag is not defined\n"
        return 1
    fi

    if [[ -n $tags[$hook] ]]; then
        (
        builtin cd -q "$tags[dir]"
        alias sudo=__zplug::utils::shell::sudo

        eval "$tags[$hook]" 2>/dev/null
        if (( $status != 0 )); then
            __zplug::io::print::f \
                --die \
                --zplug \
                --error \
                "'%s' failed\n" \
                "$tags[$hook]"
        fi
        )
    fi
}

__zplug::job::hook::build()
{
    local repo="${1:?}"

    __zplug::job::hook::service \
        "$repo" \
        "hook-build"
}

__zplug::job::hook::load()
{
    local repo="${1:?}"

    __zplug::job::hook::service \
        "$repo" \
        "hook-load"
}
