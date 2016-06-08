# cache
typeset -gx _zplug_awk_path

__zplug::utils::awk::path()
{
    local    awk_path
    local -a awk_paths
    local    awk variant

    # Look up all awk from PATH
    for awk_path in ${^path[@]}/{g,n,m,}awk
    do
        if [[ -x $awk_path ]]; then
            awk_paths+=( "$awk_path" )
        fi
    done

    # There is no awk execute file in this PATH
    if (( $#awk_paths == 0 )); then
        return 1
    fi

    # Detect awk variant from available awk list
    for awk_path in "${awk_paths[@]}"
    do
        if ${=awk_path} --version 2>&1 | grep -q "GNU Awk"; then
            # GNU Awk
            variant="gawk"
            awk="$awk_path"
            # Use gawk if it's already installed
            break
        elif ${=awk_path} -Wv 2>&1 | grep -q "mawk"; then
            # mawk
            variant=${variant:-"mawk"}
            echo $awk:$variant
        else
            # nawk
            variant="nawk"
            awk="$awk_path"
            # Search another variant if awk is nawk
            continue
        fi
    done

    if [[ $awk == "" || $variant == "mawk" ]]; then
        return 1
    fi

    echo "$awk"
}

__zplug::utils::awk::available()
{
    __zplug::utils::awk::path \
        | read awk_path
}
