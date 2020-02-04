hook global NormalKey y|d|c %{ nop %sh{
  {
    printf %s "$kak_main_reg_dquote" | wl-copy -n
  } > /dev/null 2>&1 < /dev/null &
}}

map -docstring 'append from system clipboard' \
  global user p '<a-!>wl-paste -n<ret>'
map -docstring 'insert from system clipboard' \
  global user P '!wl-paste -n<ret>'
