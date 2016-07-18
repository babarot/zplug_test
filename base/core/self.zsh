__zplug::core::self::init()
{
    local repo="zplug/zplug"
    local src="$ZPLUG_REPOS/$repo/init.zsh"
    local dst="$ZPLUG_HOME/init.zsh"

    if [[ ! -f $src ]]; then
        __zplug::io::print::f \
            --func \
            --die \
            --zplug \
            "$src: no such file or directory\n"
        return 1
    fi

    # Link
    ln -snf "$src" "$dst"
}

__zplug::core::self::check()
{
    __zplug::sources::github::check "zplug/zplug"
}

__zplug::core::self::clone()
{
    __zplug::sources::github::clone "zplug/zplug"
}

__zplug::core::self::install()
{
    __zplug::sources::github::install "zplug/zplug"
}

__zplug::core::self::uninstall()
{
    rm -rf "$ZPLUG_REPOS/zplug/zplug"
}

__zplug::core::self::update()
{
    local head

    # If there is a difference in the remote and local
    # re-install zplug by itself and initialize
    if ! __zplug::core::self::status --up-to-date; then
        __zplug::core::self::uninstall
        __zplug::core::self::install
        __zplug::core::self::init
        return $status
    fi

    __zplug::core::self::status --head \
        | read head
    __zplug::io::print::f \
        --die \
        --zplug \
        "%s (v%s) %s\n" \
        "$fg[white]up-to-date$reset_color" \
        "$_ZPLUG_VERSION" \
        "$em[under]$head[1,8]$reset_color"

    return 1
}

__zplug::core::self::load()
{
    __zplug::core::self::init
}

__zplug::core::self::status()
{
    local    arg
    local -A revisions

    __zplug::utils::git::status "zplug/zplug"
    revisions=( "$reply[@]" )

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --up-to-date)
                # local and origin/master are the same
                if [[ $revisions[local] == $revisions[master] ]]; then
                    return 0
                fi
                return 1
                ;;
            --local)
                echo "$revisions[local]"
                ;;
            --head)
                echo "$revisions[master]"
                ;;
            --version)
                echo "$revisions[$_ZPLUG_VERSION^\{\}]"
                ;;
            -*|--*)
                return 1
                ;;
        esac
        shift
    done
}
