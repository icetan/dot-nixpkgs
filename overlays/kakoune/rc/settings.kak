set global tabstop     2
set global indentwidth 2
set global scrolloff   3,5

hook global ModuleLoaded smarttab %{
  set-option global softtabstop 2
  # you can configure text that is being used to represent curent active mode
  #set-option global smarttab_expandtab_mode_name 'exp'
  #set-option global smarttab_noexpandtab_mode_name 'noexp'
  #set-option global smarttab_smarttab_mode_name 'smart'
}
eval %sh{
  printf %s\\n "set global formatcmd \"fmt -c -w ${kak_opt_autowrap_column}\""
}
