__zplug::utils::releases::get_latest()
{
    local repo="${1:?}"
    local cmd url

    repo="${1:?}"

    url="https://github.com/$repo/releases/latest"
    if (( $+commands[curl] )); then
        cmd="curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="wget -qO -"
    fi

    eval "$cmd $url" 2>/dev/null \
        | grep -o '/'"$repo"'/releases/download/[^"]*' \
        | awk -F/ '{print $6}' \
        | sort \
        | uniq
}

__zplug::utils::releases::get_state()
{
    local state
    local name="${1:?}"
    local dir="${2:?}"
    local url="https://github.com/$name/releases"

    if [[ "$(__zplug::utils::releases::get_latest "$name")" == "$(cat "$dir/INDEX")" ]]; then
        state="up to date"
    else
        state="local out of date"
    fi

    case "$state" in
        "local out of date")
            state="${fg[red]}${state}${reset_color}"
            ;;
        "up to date")
            state="${fg[green]}${state}${reset_color}"
            ;;
    esac
    __zplug::io::print::put "($state) '${url:-?}'\n"
}

__zplug::utils::releases::is_64()
{
    uname -m | grep -q "64$"
}

__zplug::utils::releases::get_url()
{
    local    repo="${1:?}"
    local    tag_use tag_at
    local    cmd url
    local -i arch=386
    local -a candidates
    local    result

    {
        tag_use="$(__use__ "$repo")"
        tag_at="$(__at__ "$repo")"

        #if [[ $tag_use == '*.zsh' ]]; then
        #    tag_use=
        #fi
        #if [[ $tag_at == "master" ]]; then
        #    tag_at="latest"
        #fi

        #if [[ -n $tag_at && $tag_at != "latest" ]]; then
        #    tag_at="tag/$tag_at"
        #else
        #    tag_at="latest"
        #fi

        #if [[ -n $tag_use ]]; then
        #    tag_use="$(__zplug::utils::shell::glob2regexp "$tag_use")"
        #else
        #    tag_use="$(__zplug::base::base::get_os)"
        #    if __zplug::base::base::is_osx; then
        #        tag_use="(darwin|osx)"
        #    fi
        #fi
    }

    # Get machine information
    if __zplug::utils::releases::is_64; then
        arch="64"
    fi

    url="https://github.com/$repo/releases/$tag_at"
    if (( $+commands[curl] )); then
        cmd="curl -fsSL"
    elif (( $+commands[wget] )); then
        cmd="wget -qO -"
    fi

    candidates=(
    ${(@f)"$(
    eval "$cmd $url" 2>/dev/null \
        | grep -o '/'"$repo"'/releases/download/[^"]*'
    )"}
    )
    if (( $#candidates == 0 )); then
        __zplug::io::print::die \
            "$repo: there are no available releases\n"
        return 1
    fi

    echo "${(F)candidates[@]}" \
        | grep -E "${tag_use:-}" \
        | grep "$arch" \
        | head -n 1 \
        | read result

    if [[ -z $result ]]; then
        __zplug::io::print::die "$repo: repository not found\n"
        return 1
    fi

    echo "https://github.com$result"
}

__zplug::utils::releases::get()
{
    local    url="${1:?}"
    local    repo dir header artifact cmd

    # make 'username/reponame' style
    repo="${url:s-https://github.com/--:F[4]h}"

    dir="$ZPLUG_REPOS/$repo"
    header="${url:h:t}"
    artifact="${url:t}"

    if (( $+commands[curl] )); then
        cmd="curl -L -O"
    elif (( $+commands[wget] )); then
        cmd="wget"
    fi

    (
    mkdir -p "$dir"
    builtin cd -q "$dir"

    # Grab artifact from G-R
    eval "$cmd $url" &>/dev/null

    __zplug::utils::releases::index \
        "$repo" \
        "$artifact" \
        &>/dev/null &&
        echo "$header" >"$dir/INDEX"
    )

    return $status
}

__zplug::utils::releases::index()
{
    local    repo="$1" artifact="$2"
    local    cmd="${repo:t}"
    local -a binaries

    case "$artifact" in
        *.zip)
            unzip "$artifact" &>/dev/null
            rm -f "$artifact" &>/dev/null
            ;;
        *.tar.gz|*.tgz)
            tar xvf "$artifact" &>/dev/null
            rm -f "$artifact"   &>/dev/null
            ;;
        *.*)
            __zplug::io::print::die \
                "$artifact: Unknown extension format\n"
            return 1
            ;;
        *)
            # Through
            ;;
    esac

    binaries=(
    $(
    file **/*(N-.) \
        | awk -F: '$2 ~ /executable/{print $1}'
    )
    )

    if (( $#binaries == 0 )); then
        __zplug::io::print::die \
            "$cmd: Failed to grab binaries from GitHub Releases\n"
        return 1
    fi

    {
        mv -f "$binaries[1]" "$cmd"
        chmod 755 "$cmd"
        rm -rf *~"$cmd"(N)
    } &>/dev/null

    if [[ ! -x $cmd ]]; then
        __zplug::io::print::die \
            "$repo: Failed to install\n"
        return 1
    fi

    __zplug::io::print::put \
        "$repo: Installed successfully\n"

    return 0
}
