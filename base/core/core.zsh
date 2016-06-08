__zplug::core::core::get_interfaces()
{
    :
}

__zplug::core::core::run_interfaces()
{
    local arg="${1:?}"; shift
    local underscore

    underscore="__${arg}__"

    if (( ! $+functions[$underscore] )); then
        autoload -Uz "$underscore"
    fi

    # Execute
    ${=underscore} "$@"
}

__zplug::core::core::reload()
{
    :
}

__zplug::core::core::variable()
{
    # for 'autoload -Uz zplug' in another subshell
    export FPATH="$ZPLUG_ROOT/autoload:$FPATH"

    typeset -gx ZPLUG_HOME=${ZPLUG_HOME:-~/.zplug}
    typeset -gx ZPLUG_THREADS=${ZPLUG_THREADS:-16}
    typeset -gx ZPLUG_CLONE_DEPTH=${ZPLUG_CLONE_DEPTH:-0}
    typeset -gx ZPLUG_PROTOCOL=${ZPLUG_PROTOCOL:-HTTPS}
    typeset -gx ZPLUG_FILTER=${ZPLUG_FILTER:-"fzf-tmux:fzf:peco:percol:fzy:zaw"}
    typeset -gx ZPLUG_LOADFILE=${ZPLUG_LOADFILE:-$ZPLUG_HOME/packages.zsh}
    typeset -gx ZPLUG_USE_CACHE=${ZPLUG_USE_CACHE:-true}
    typeset -gx ZPLUG_CACHE_FILE=${ZPLUG_CACHE_FILE:-$ZPLUG_HOME/.cache}
    typeset -gx ZPLUG_REPOS=${ZPLUG_REPOS:-$ZPLUG_HOME/repos}
    typeset -gx _ZPLUG_VERSION="2.1.0"
    typeset -gx _ZPLUG_URL="https://github.com/zplug/zplug"
    typeset -g  _ZPLUG_OHMYZSH="robbyrussell/oh-my-zsh"
    typeset -g  _ZPLUG_AWKPATH="$ZPLUG_ROOT/misc/contrib"
    typeset -gx ZPLUG_SUDO_PASSWORD

    #__zplug::base::base::get_tags
    #typeset -ga _zplug_tag_pattern
    #_zplug_tag_pattern=( "${reply[@]}" )

    if (( $+ZPLUG_SHALLOW )); then
        __zplug::io::print::die \
            "[zplug] $fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color: ZPLUG_SHALLOW is deprecated. "
        __zplug::io::print::die \
            "Please use 'export ZPLUG_CLONE_DEPTH=1' instead.\n"
    fi

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

    # zplug core variables
    {
        typeset -gx -A -U \
            _zplug_options \
            _zplug_commands \
            _zplug_tags

        __zplug::core::options::get; _zplug_options=( "${reply[@]}" )
        __zplug::core::commands::get; _zplug_commands=( "${reply[@]}" )
        __zplug::core::tags::get; _zplug_tags=( "${reply[@]}" )
    }

    # boolean
    {
        typeset -ga \
            _zplug_boolean_true \
            _zplug_boolean_false

        _zplug_boolean_true=("true" "yes" "on" 1)
        _zplug_boolean_false=("false" "no" "off" 0)
    }
}
