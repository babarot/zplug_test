__zplug::core::sources::is_exists()
{
    local source_name="${1:?}"

    [[ -f $ZPLUG_ROOT/base/sources/$source_name.zsh ]]
    return $status
}

__zplug::core::sources::is_handler_defined()
{
    local subcommand source_name handler_name

    subcommand="${1:?}"
    source_name="${2:?}"
    handler_name="__zplug::sources::$source_name::$subcommand"

    if ! __zplug::core::sources::is_exists "$source_name"; then
        return 1
    fi

    (( $+functions[$handler_name] ))
    return $status
}

# Call the handler of the external source if defined
__zplug::core::sources::use_handler()
{
    local subcommand source_name handler_name repo

    subcommand="${1:?}"
    source_name="${2:?}"
    handler_name="__zplug::sources::$source_name::$subcommand"
    repo="${3:?}"

    case "$repo" in
        "zplug/zplug")
            handler_name="__zplug::core::self::$subcommand"
            (( $+functions[$handler_name] )) || return 1
            ;;
        *)
            if ! __zplug::core::sources::is_handler_defined "$subcommand" "$source_name"; then
                # Callback function undefined
                return 1
            fi

            ;;
    esac

    eval "$handler_name '$repo'"
    return $status
}

__zplug::core::sources::call()
{
    local val="${1:?}"

    if __zplug::core::sources::is_exists "$val"; then
        autoload -Uz "$val.zsh"
        eval "$val.zsh"
        unfunction "$val.zsh"
    fi
}

__zplug::core::sources::use_default()
{
    local val

    # Get the default value
    val="$(__zplug::core::core::run_interfaces 'from')"

    __zplug::core::sources::call "$val"
}
