__zplug::io::file::load()
{
    if [[ -f $ZPLUG_LOADFILE ]]; then
        source "$ZPLUG_LOADFILE"
        return $status
    else
        return 1
    fi
}

__zplug::io::file::generate()
{
    if [[ -f $ZPLUG_LOADFILE ]]; then
        return 0
    fi

    cat <<-TEMPLATE >$ZPLUG_LOADFILE
#!/bin/zsh
# -*- mode: zsh -*-
# vim:ft=zsh
#
# *** ZPLUG EXTERNAL FILE ***
# You can register plugins or commands to zplug on the
# command-line. If you use zplug on the command-line,
# it is possible to write more easily its settings
# by grace of the command-line completion.
# In this case, zplug spit out its settings to
# $ZPLUG_LOADFILE instead of .zshrc.
# If you launch new zsh process, zplug load command
# automatically search this file and run source command.
#
#
# Example:
# zplug "b4b4r07/enhancd", as:plugin, use:"*.sh"
# zplug "rupa/z",          as:plugin, use:"*.sh"
#
TEMPLATE
}

__zplug::io::file::append()
{
    __zplug::io::file::generate
    __zplug::io::print::put \
        "$@\n" \
        >>|"$ZPLUG_LOADFILE"
}
