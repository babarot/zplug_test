__zplug::core::core::get_interfaces()
{
    local    arg name desc
    local    target
    local -a targets
    local    interface
    local -A interfaces
    local    is_key=false is_prefix=false

    while (( $# > 0 ))
    do
        arg="$1"
        case "$arg" in
            --key)
                is_key=true
                ;;
            --prefix)
                is_prefix=true
                ;;
            -* | --*)
                ;;
            "")
                ;;
            *)
                targets+=( "$arg" )
                ;;
        esac
        shift
    done

    # Initialize
    reply=()

    for target in "${targets[@]}"
    do
        interfaces=()
        for interface in "$ZPLUG_ROOT/autoload/$target"/__*__(N-.)
        do
            # TODO: /^.*desc(ription)?: ?/
            name="${interface:t:gs:_:}"
            if $is_prefix; then
                name="__${name}__"
            fi
            cat "$interface" \
                | awk '
                $0 ~ "# Description:" {
                    getline
                    sub(/^# */, "")
                    print $0
                }' \
                | read desc
            interfaces[$name]="$desc"
        done

        if $is_key; then
            reply+=( "${(k)interfaces[@]}" )
        else
            reply+=( "${(kv)interfaces[@]}" )
        fi
    done
}

__zplug::core::core::run_interfaces()
{
    local    arg="${1:?}"; shift
    local    interface
    local -i ret=0

    interface="__${arg:gs:_:}__"

    # Do autoload if not exists in $functions
    if (( ! $+functions[$interface] )); then
        autoload -Uz "$interface"
    fi

    # $interface does not exist in fpath
    # even if do run autoload -Uz command
    #if ! __zplug::base::base::is_autoload "$interface"; then
    #    __zplug::io::print::f \
    #        --die \
    #        --zplug \
    #        "$interface: is not autoload file\n"
    #    return 1
    #fi

    # Execute
    ${=interface} "$argv[@]"
    ret=$status

    # TODO:
    unfunction "$interface" &>/dev/null

    return $ret
}

__zplug::core::core::reload()
{
    __zplug::core::core::get_interfaces \
        --key --prefix \
        "options" \
        "commands" \
        "tags"

    unfunction "$reply[@]"
    autoload -Uz "$reply[@]"
}

__zplug::core::core::variable()
{
    # for 'autoload -Uz zplug' in another subshell
    export FPATH="$ZPLUG_ROOT/autoload:$FPATH"

    typeset -gx    ZPLUG_HOME=${ZPLUG_HOME:-~/.zplug}
    typeset -gx -i ZPLUG_THREADS=${ZPLUG_THREADS:-16}
    typeset -gx -i ZPLUG_CLONE_DEPTH=${ZPLUG_CLONE_DEPTH:-0}
    typeset -gx    ZPLUG_PROTOCOL=${ZPLUG_PROTOCOL:-HTTPS}
    typeset -gx    ZPLUG_FILTER=${ZPLUG_FILTER:-"fzf-tmux:fzf:peco:percol:fzy:zaw"}
    typeset -gx    ZPLUG_LOADFILE=${ZPLUG_LOADFILE:-$ZPLUG_HOME/packages.zsh}
    typeset -gx    ZPLUG_USE_CACHE=${ZPLUG_USE_CACHE:-true}
    typeset -gx    ZPLUG_CACHE_FILE=${ZPLUG_CACHE_FILE:-$ZPLUG_HOME/.cache}
    typeset -gx    ZPLUG_REPOS=${ZPLUG_REPOS:-$ZPLUG_HOME/repos}
    typeset -gx    _ZPLUG_VERSION="2.1.0"
    typeset -gx    _ZPLUG_URL="https://github.com/zplug/zplug"
    typeset -gx    _ZPLUG_OHMYZSH="robbyrussell/oh-my-zsh"
    typeset -gx    _ZPLUG_AWKPATH="$ZPLUG_ROOT/misc/contrib"
    typeset -gx    ZPLUG_SUDO_PASSWORD

    #__zplug::base::base::get_tags
    #typeset -ga _zplug_tag_pattern
    #_zplug_tag_pattern=( "${reply[@]}" )

    if (( $+ZPLUG_SHALLOW )); then
        __zplug::io::print::f \
            --die \
            --zplug \
            --warn \
            "ZPLUG_SHALLOW is deprecated." \
            "Please use 'export ZPLUG_CLONE_DEPTH=1' instead.\n"
    fi

    # zplug core variables
    {
        typeset -gx -A -U \
            _zplug_options \
            _zplug_commands \
            _zplug_tags

        __zplug::core::options::get; _zplug_options=( "${reply[@]}" )
        __zplug::core::commands::get; _zplug_commands=( "${reply[@]}" )
        __zplug::core::tags::get; _zplug_tags=( "${reply[@]}" )

        #typeset -gx -a -U _zplug_interfaces
        #_zplug_interfaces=(
        #__${^${(k)_zplug_options[@]}}__
        #__${^${(k)_zplug_commands[@]}}__
        #__${^${(k)_zplug_tags[@]}}__
        #)
    }

    # boolean
    {
        typeset -gx -a \
            _zplug_boolean_true \
            _zplug_boolean_false

        _zplug_boolean_true=("true" "yes" "on" 1)
        _zplug_boolean_false=("false" "no" "off" 0)
    }

    # context ":zplug:config:setopt"
    {
        local -a only_subshell
        typeset -gx _ZPLUG_CONFIG_SUBSHELL=":"

        zstyle -a ":zplug:config:setopt" \
            only_subshell \
            only_subshell
        zstyle -t ":zplug:config:setopt" \
            same_curshell

        if (( $_zplug_boolean_true[(I)$same_curshell] )); then
            only_subshell=(
            "${only_subshell[@]:gs:_:}"
            $(setopt)
            )
        fi

        if (( $#only_subshell > 0 )); then
            _ZPLUG_CONFIG_SUBSHELL="setopt ${(u)only_subshell[@]}"
        fi
    }
}
