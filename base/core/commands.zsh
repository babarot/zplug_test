__zplug::core::commands::get()
{
    local    cmd cmd_name cmd_path
    local -A commands

    for cmd in "$ZPLUG_ROOT/autoload/commands"/__*__
    do
        cmd_name="${cmd:t:gs:_:}"
        cmd_path="$cmd"
        commands[$cmd_name]="$cmd_path"
    done

    reply=( "${(kv)commands[@]}" )
}

__zplug::core::commands::user_defined()
{
    local -a user_cmds

    reply=()

    user_cmds=( ${^path[@]}/zplug-*(N-.:t:gs:zplug-:) )
    if (( $#user_cmds > 0 )); then
        # Unique
        reply+=( "${(u)user_cmds[@]}" )
        return 0
    fi

    return 1
}
