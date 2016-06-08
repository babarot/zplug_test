__zplug::sources::oh-my-zsh::check()
{
    local    repo="$1"
    local -A tags

    tags[dir]="$(__zplug::core::core::run_interfaces 'dir' "$repo")"

    [[ -d $tags[dir]:h ]]
    return $status
}

__zplug::sources::oh-my-zsh::install()
{
    # Already cloned
    if [[ -d $_ZPLUG_OHMYZSH ]]; then
        return 0
    fi

    __zplug::utils::git::clone \
        "$_ZPLUG_OHMYZSH"
    return $status
}

__zplug::sources::oh-my-zsh::update()
{
    local repo="${1:?}"
    local top_dir="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
    local rev_local rev_remote rev_base
    local -A tags

    tags[dir]="$top_dir"
    tags[at]="$(__zplug::core::core::run_interfaces 'at' "$repo")"

    {
        # EXIT CODE
        # 0: Updated successfully
        # 1: Failed to update
        # 2: Repo is not found
        # 3: Repo has frozen tag
        # 4: Up-to-date

        builtin cd -q $tags[dir] || return 2

        if [[ -e $tags[dir]/.git/shallow ]]; then
            git fetch --unshallow
        else
            git fetch
        fi
        git checkout -q "$tags[at]"

        rev_local="$(git rev-parse HEAD)"
        rev_remote="$(git rev-parse "@{u}")"
        rev_base="$(git merge-base HEAD "@{u}")"

        if [[ $rev_local == $rev_remote ]]; then
            # up-to-date
            return 4
        elif [[ $rev_local == $rev_base ]]; then
            # need to pull
            git merge --ff-only origin/$tags[at] \
                && git submodule update --init --recursive
            # It can be expected to be successful
            return $status
        elif [[ $rev_remote == $rev_base ]]; then
            # need to push
            return 1
        else
            # Diverged
            return 1
        fi
    } &>/dev/null

    # success
    return 0
}

__zplug::sources::oh-my-zsh::clone()
{
    local repo="$_ZPLUG_OHMYZSH"
    local target="${1:?}"

    case $ZPLUG_PROTOCOL in
        HTTPS | https)
            # https://git::@github.com/%s.git
            url_format="https://git::@gist.github.com/${repo}.git"

            if __zplug::base::base::git_version 2.3; then
                # (git 2.3+) https://gist.github.com/%s.git
                export GIT_TERMINAL_PROMPT=0
                url_format="https://gist.github.com/${repo}.git"
            fi
            ;;
        SSH | ssh)
            # git@github.com:%s.git
            url_format="git@gist.github.com:${repo}.git"
            ;;
    esac

    tag_depth="$(
    __zplug::core::core::run_interfaces \
        'depth' \
        "$repo"
    )"
    if (( $tag_depth == 0 )); then
        tag_depth=""
    else
        tag_depth="--depth=$tag_depth"
    fi

    git clone \
        ${=tag_depth} \
        --recursive \
        --quiet \
        "$url_format" "$ZPLUG_REPOS/$repo" &>/dev/null
}

__zplug::sources::oh-my-zsh::load_plugin()
{
    local    repo="${1:?}"
    local -A tags
    local -a load_fpaths
    local -a load_patterns
    local -a themes_ext

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    load_fpaths=()
    load_patterns=()
    # Themes' extensions for Oh-My-Zsh
    themes_ext=("zsh-theme" "theme-zsh")

    # Check if omz is loaded and set some necessary settings
    if [[ -z $ZSH ]]; then
        export ZSH="$ZPLUG_REPOS/$_ZPLUG_OHMYZSH"
        export ZSH_CACHE_DIR="$ZSH/cache/"
        # Insert to the top of load_plugins
        # load_plugins=(
        #     "$ZSH/oh-my-zsh.sh"
        #     "${load_plugins[@]}"
        # )
        if [[ $tags[name] =~ ^lib ]]; then
            __zplug::utils::omz::theme
        fi
    fi

    case $tags[name] in
        plugins/*)
            # TODO: use tag
            load_patterns=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                "$tags[dir]"/*.plugin.zsh(N-.)
            )
            ;;
        themes/*)
            # TODO: use tag
            load_patterns=(
                ${(@f)"$(__zplug::utils::omz::depends "$tags[name]")"}
                "$tags[dir]".${^themes_ext}(N-.)
            )
            ;;
        lib/*)
            load_patterns=(
                "$tags[dir]"${~tags[use]}
            )
            ;;
    esac
    load_fpaths+=(
        ${tags[dir]}/{_*,**/_*}(N-.:h)
    )

    reply=()
    [[ -n $load_fpaths ]] && reply+=( load_fpaths "${(F)load_fpaths}" )
    [[ -n $load_patterns ]] && reply+=( load_patterns "${(F)load_patterns}" )

    return 0
}
