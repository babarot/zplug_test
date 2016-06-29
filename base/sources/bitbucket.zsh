__zplug::sources::bitbucket::check()
{
    __zplug::sources::github::check "$argv[@]"
}

__zplug::sources::bitbucket::install()
{
    __zplug::sources::github::install "$argv[@]"
}

__zplug::sources::bitbucket::update()
{
    __zplug::sources::github::update "$argv[@]"
}

__zplug::sources::bitbucket::clone()
{
    local repo="$1"

    case $ZPLUG_PROTOCOL in
        HTTPS | https)
            # https://git::@bitbucket.org/%s.git
            url_format="https://git::@bitbucket.org/${repo}.git"
            ;;
        SSH | ssh)
            # git@bitbucket.org:%s.git
            url_format="git@bitbucket.org:${repo}.git"
            ;;
    esac

    if [[ -z $url_format ]]; then
        __zplug::io::print::die \
            --die \
            --zplug \
            --error \
            "$repo is an invalid 'user/repo' format.\n"
        return 1
    fi

    tag_depth="--depth=$(__depth__ "$repo")"

    git clone \
        $tag_depth \
        --recursive \
        --quiet \
        "$url_format" "$ZPLUG_REPOS/$repo" &>/dev/null
}

__zplug::sources::bitbucket::load_plugin()
{
    __zplug::sources::github::load_plugin "$argv[@]"
}

__zplug::sources::bitbucket::load_command()
{
    __zplug::sources::github::load_command "$argv[@]"
}
