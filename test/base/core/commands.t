source "$ZPLUG_ROOT/init.zsh"

T_SUB "__zplug::core::commands::get" ((
  # skip
  return 0

  local expect actual

  expect="check clean clear info install list load status update status"

  __zplug::core::commands::get --key
  echo ${(o)reply[*]}
  actual=${(o)reply[*]}

  t_is "$expect" "$actual"
))

T_SUB "__zplug::core::commands::user_defined" ((
  # skip
))
