__zplug::base::test::log_new()
{
    __zplug::io::log::new \
        --level='DEBUG' \
        "it's fail"
    return 1
}

__zplug::base::test::log_captcha()
{
    function() {
        echo "fatal error" >&2
        return 1
    } \
        2> >(__zplug::io::log::captcha) >/dev/null
    return 1
}
