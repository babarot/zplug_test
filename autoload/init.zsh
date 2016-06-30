# This file just loads some files within autoload directory
# Also, load the body of zplug

autoload -Uz add-zsh-hook
autoload -Uz colors
autoload -Uz compinit
autoload -Uz zplug

colors

()
{
    local opt cmd tag

    for opt in "${(k)_zplug_options[@]}"
    do
        autoload -Uz "__${opt}__"
    done

    for cmd in "${(k)_zplug_commands[@]}"
    do
        autoload -Uz "__${cmd}__"
    done

    for tag in "${(k)_zplug_tags[@]}"
    do
        autoload -Uz "__${tag}__"
    done
}
