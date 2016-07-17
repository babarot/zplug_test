__zplug::core::self::check()
{
    local repo="${1:?}"

    [[ -d $ZPLUG_REPOS/$repo ]]
    return $status
}

__zplug::core::self::install()
{
    __zplug::core::self::clone "$argv[@]"
}

__zplug::core::self::clone()
{
    local repo="${1:?}"
    local zplug_url="https://github.com/$repo.git"
    local tag_depth

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
        "$zplug_url" "$ZPLUG_REPOS/$repo" &>/dev/null

    if (( $status != 0 )); then
        return 1
    fi
}

__zplug::core::self::update()
{
    local repo="${1:?}"
}

__zplug::core::self::load()
{
    local repo="${1:?}"
    local src="$ZPLUG_REPOS/$repo/init.zsh"
    local dst="$ZPLUG_HOME/init.zsh"

    if [[ ! -f $src ]]; then
        __zplug::io::print::f \
            --die \
            --zplug \
            "$src: no such file or directory\n"
        return 1
    fi

    # Link
    ln -snf "$src" "$dst"
}

__zplug::core::self::status()
{
    local    repo="${1:?}"
    local    key val line
    local -A remotes

    git ls-remote --heads --tags https://github.com/"$repo".git \
        | awk '{print $2,$1}' \
        | sed -E 's@^refs/(heads|tags)/@@g' \
        | while read line; do
            key=${${(s: :)line}[1]}
            val=${${(s: :)line}[2]}
            remotes[$key]=$val
        done

    git \
        --git-dir=$ZPLUG_ROOT/.git \
        --work-tree=$ZPLUG_ROOT \
        log \
        --oneline \
        --pretty="format:%H" \
        --max-count=1 \
        | read rev
    echo "+------------+------------------------------------------+"
    command printf "| %-10s | %40s |\n" \
        "NOW" "$rev" \
        "HEAD" "${remotes[master]}" \
        "$_ZPLUG_VERSION" "${remotes[$_ZPLUG_VERSION^\{\}]}"
    echo "+------------+------------------------------------------+"
}
