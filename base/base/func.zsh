__zplug::base::func::return()
{
    local exit_code="$1"

    case "$exit_code" in
        "true")
            return 0
            ;;
        "false")
            return 1
            ;;
        <->)
            # positive number
            return $exit_code
            ;;
        -<->)
            # negative number
            zmodload zsh/mathfunc || return 1
            echo $(( abs(256 + exit_code) ))
            ;;
        "")
            # no argument is given
            return 0
            ;;
        *)
            # string
            echo "$exit_code"
            ;;
    esac
}
