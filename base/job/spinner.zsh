typeset -g spin_file="/tmp/.spin.$$$RANDOM"

__zplug::job::spinner::is_spin()
{
    [[ -f $spin_file ]]
    return $status
}

__zplug::job::spinner::lock()
{
    __zplug::job::spinner::is_spin && return 1

    set +m
    touch $spin_file
}

__zplug::job::spinner::unlock()
{
    __zplug::job::spinner::is_spin || return 1

    rm -f "$spin_file" &>/dev/null
}

__zplug::job::spinner::spin()
{
    local    spinner format="@"
    local -F latency=0.05
    local -a spinners

    spinners=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

    tput civis

    while __zplug::job::spinner::is_spin
    do
        for spinner in "${spinners[@]}"
        do
            __zplug::job::spinner::is_spin || break

            printf " $spinner\r" >/dev/stderr
            sleep "$latency"
        done
    done

    tput cnorm
    set -m
}

__zplug::job::spinner::echo()
{
    __zplug::job::spinner::is_spin || return 1
    __zplug::io::print::put "$@"
}
