__zplug::core::v1::tags()
{
    local key="${1:?}" new_key

    case "$key" in
        "of")
            new_key="use"
            ;;
        "file")
            new_key="rename-to"
            ;;
        "commit")
            new_key="at"
            ;;
        "do")
            new_key="hook-build"
            ;;
    esac

    __zplug::io::print::die \
        "[zplug] $fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color: '$fg[blue]$key$reset_color' tag is deprecated. "
    __zplug::io::print::die \
        "Please use '$fg[blue]$new_key$reset_color' tag instead ($fg[green]${name:gs:@::}$reset_color).\n"

    return 1
}

__zplug::core::v1::pipe()
{
    __zplug::io::print::die \
        "[zplug] $fg[red]${(%):-"%U"}WARNING${(%):-"%u"}$reset_color: pipe syntax is deprecated!\n"
    __zplug::io::print::die \
        "[zplug] Please use '$fg[blue]on$reset_color' tag instead.\n"
    return 1
}
