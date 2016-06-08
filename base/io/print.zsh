__zplug::io::print::put()
{
    command printf -- "$@"
}

__zplug::io::print::die()
{
    command printf -- "$@" >&2
}
