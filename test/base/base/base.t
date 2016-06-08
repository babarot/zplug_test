source "$ZPLUG_ROOT/init.zsh"

T_SUB "__zplug::base::base::is_cli" ((
  # skip
))

T_SUB "__zplug::base::base::zpluged" ((
  local -A zplugs
  zplugs=("my_plugin" "as:plugin")

  __zplug::base::base::zpluged "my_plugin"
  t_is $status 0

  __zplug::base::base::zpluged "some_plugin"
  t_isnt $status 0
))

T_SUB "__zplug::base::base::version_requirement" ((
  __zplug::base::base::version_requirement 1.0 1.0
  t_is $status 0

  __zplug::base::base::version_requirement 1.2 1.1
  t_is $status 0

  __zplug::base::base::version_requirement 1.1 1.2
  t_isnt $status 0
))

T_SUB "__zplug::base::base::git_version" ((
  # skip
))

T_SUB "__zplug::base::base::zsh_version" ((
  # skip
))

T_SUB "__zplug::base::base::osx_version" ((
  # skip
))

T_SUB "__zplug::base::base::get_os" ((
  # skip
))

T_SUB "__zplug::base::base::is_osx" ((
  # skip
))

T_SUB "__zplug::base::base::is_linux" ((
  # skip
))

T_SUB "__zplug::base::base::packaging" ((
  # skip
))

T_SUB "__zplug::base::base::is_autoload" ((
  # skip
))
