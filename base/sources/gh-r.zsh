__zplug::sources::gh-r::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"

    # Repo's directory is not found and
    # INDEX file is not found
    if [[ ! -d $tags[dir] ]] && [[ ! -f $tags[dir]/INDEX ]]; then
        return 1
    fi

    return 0
}

__zplug::sources::gh-r::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::gh-r::update()
{
    local repo="${1:?}"
    local repo_path="$ZPLUG_REPOS/$repo"
    local index url
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"
    tags[use]="$(__zplug::core::core::run_interfaces 'use' "$repo")"
    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"

    __zplug::utils::shell::cd "$tags[dir]" || return 1

    url="$(
    __zplug::utils::releases::get_url \
        "$repo"
    )"

    # EXIT CODE
    # 0: Updated successfully
    # 1: Failed to update
    # 2: Repo is not found
    # 3: Repo has frozen tag
    # 4: Up-to-date
    if [[ -d $repo_path ]]; then
        # Update
        if [[ -f $repo_path/INDEX ]]; then
            index="$(<"$repo_path/INDEX")"
            if [[ $tags[at] == "latest" ]]; then
                if grep -q "$index" <<<"$url"; then
                    # up-to-date
                    return 4
                else
                    __zplug::sources::gh-r::clone "$repo"
                    return $status
                fi
            else
                # up-to-date
                return 1
            fi
        fi
    else
        # Not found
        return 2
    fi
}

__zplug::sources::gh-r::clone()
{
    local repo="${1:?}"
    local url

    url="$(
    __zplug::utils::releases::get_url \
        "$repo"
    )"

    __zplug::utils::releases::get "$url"

    return $status
}

__zplug::sources::gh-r::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}
