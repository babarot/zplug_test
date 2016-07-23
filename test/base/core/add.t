source "$ZPLUG_ROOT/init.zsh"

T_SUB "__zplug::core::add::to_zplugs" ((
  zplugs=()
  __zplug::core::add::to_zplugs "b4b4r07/enhancd"
  t_is $status 0
  t_is $#zplugs 1
))

T_SUB "__zplug::core::add::proc_at-sign" ((
  local expect actual

  zplugs=()
  zplugs+=("b4b4r07/enhancd" "as:plugin")

  expect="b4b4r07/enhancd@"
  __zplug::core::add::proc_at-sign \
    "b4b4r07/enhancd" \
    | read actual

  t_is "$expect" "$actual"
))
