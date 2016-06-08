#!/usr/bin/env zsh

typeset -gx ZPLUG_ROOT="${${(%):-%N}:A:h}"

typeset -gx -A zplugs
zplugs=()

# Unique array
typeset -gx -U path
typeset -gx -U fpath

# Add to the PATH
path=(
"$ZPLUG_ROOT"/bin
"$path[@]"
)

# Add to the FPATH
fpath=(
"$ZPLUG_ROOT"/autoload(N-/)
"$ZPLUG_ROOT"/autoload/*(N-/)
"$ZPLUG_ROOT"/misc/completions(N-/)
"$ZPLUG_HOME/base/sources"
"$fpath[@]"
)

# Load basic functions such as an __zplug::base function
source "$ZPLUG_ROOT/base/init.zsh"

__zplug::base "base/*"
__zplug::base "core/*"
__zplug::base "io/*"
__zplug::base "job/*"
__zplug::base "sources/*"
__zplug::base "utils/*"

__zplug::core::core::variable

# Check whether you meet the requirements for using zplug
# 1. zsh 4.3.9 or more
# 2. git
# 3. nawk or gawk
{
    if ! __zplug::base::base::zsh_version 4.3.9; then
        __zplug::io::print::die "[zplug] zplug does not work this version of zsh $ZSH_VERSION.\n"
        __zplug::io::print::die "        You must use zsh 4.3.9 or later.\n"
        return 1
    fi

    if (( ! $+commands[git] )); then
        __zplug::io::print::die "[zplug] git command not found in \$PATH\n"
        __zplug::io::print::die "        zplug depends on git 1.7 or later.\n"
        return 1
    fi
}

mkdir -p "$ZPLUG_REPOS"
mkdir -p "$ZPLUG_HOME/bin"

# Load main file
source "$ZPLUG_ROOT/autoload/init.zsh"

if (( ! $+functions[_zplug] )); then
    compinit
fi
