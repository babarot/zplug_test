source "$ZPLUG_ROOT/init.zsh"

T_SUB "__zplug::core::arguments::exec" ((
  # skip
))

T_SUB "__zplug::core::arguments::auto_correct" ((
  local    arg="instakk" expect actual
  local -a reply_cmds

  __zplug::core::commands::user_defined
  reply_cmds+=( "${reply[@]}" )

  __zplug::core::commands::get --key
  reply_cmds+=( "${reply[@]}" )

  expect="install"
  awk \
      -f "$_ZPLUG_AWKPATH/fuzzy.awk" \
      -v search_string="$arg" \
      <<<"${(F)reply_cmds:gs:_:}" \
      | read actual

  t_is "$expect" "$actual"
))

T_SUB "__zplug::core::arguments::none" ((
  # skip
))
