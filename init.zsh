#!/usr/bin/env zsh

# Hash Array for zplug
typeset -gx -A zplugs
zplugs=()

typeset -gx ZPLUG_ROOT="${${(%):-%N}:A:h}"

# Unique array
typeset -gx -U path
typeset -gx -U fpath

# Add to the PATH
path=(
"$ZPLUG_ROOT"/bin
"$ZPLUG_HOME"/bin
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
# Load autoloader
source "$ZPLUG_ROOT/autoload/init.zsh"

__zplug::base "base/*"
__zplug::base "core/*"
__zplug::base "io/*"
__zplug::base "job/*"
__zplug::base "sources/*"
__zplug::base "utils/*"

# Check whether you meet the requirements for using zplug
# 1. zsh 4.3.9 or more
# 2. git
# 3. nawk or gawk
{
    if ! __zplug::base::base::zsh_version 4.3.9; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "zplug does not work this version of zsh $ZSH_VERSION.\n" \
            "You must use zsh 4.3.9 or later.\n"
        return 1
    fi

    if ! __zplug::base::base::git_version 1.7; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            "git command not found in \$PATH\n" \
            "zplug depends on git 1.7 or later.\n"
        return 1
    fi

    if ! __zplug::utils::awk::available; then
        __zplug::io::print::f \
            --die \
            --zplug \
            --error \
            'No available AWK variant in your $PATH\n'
        return 1
    fi
}

# Release zplug variables and export
__zplug::core::core::variable

mkdir -p "$ZPLUG_REPOS"
mkdir -p "$ZPLUG_HOME/bin"

# Run compinit if zplug comp file hasn't load
if (( ! $+functions[_zplug] )); then
    compinit
fi

# Load external file of zplug
__zplug::io::file::load
