__zplug::sources::gist::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::gist::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::gist::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::gist::clone()
{
    local repo="${1:?}"

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

    if [[ -z $url_format ]]; then
        __zplug::io::print::die \
            "[zplug] $fg[red]ERROR$reset_color: $repo is an invalid 'user/repo' format.\n"
        return 1
    fi

    tag_depth="--depth=$(__depth__ "$repo")"

    git clone \
        $tag_depth \
        --recursive \
        --quiet \
        "$url_format" "$ZPLUG_REPOS/$repo" &>/dev/null
}

__zplug::sources::gist::load_plugin()
{
    __zplug::sources::github::load_plugin "$@"
}

__zplug::sources::gist::load_command()
{
    __zplug::sources::github::load_command "$@"
}
