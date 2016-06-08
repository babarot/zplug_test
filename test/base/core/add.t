source "$ZPLUG_ROOT/init.zsh"

T_SUB "__zplug::core::add::to_zplugs" ((
  __zplug::core::add::to_zplugs "a/b"
  t_is $status 0
))

T_SUB "__zplug::core::add::proc_at-sign" ((
  # skip
))
