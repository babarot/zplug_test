__zplug::sources::call::this()
{
    local val="${1:?}"

    if __zplug::base::base::is_external "$val"; then
        autoload -Uz "$val.zsh"
        eval "$val.zsh"
        unfunction "$val.zsh"
    fi
}

__zplug::sources::call::default()
{
    local val
    val="$(__from__)"
    __zplug::sources::call::this "$val"
}
