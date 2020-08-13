hook global NormalKey y|d|c %{ nop %sh{
  {
    printf %s "$kak_main_reg_dquote" | xsel -ib
  } > /dev/null 2>&1 < /dev/null &
}}

map -docstring 'append from system clipboard' \
  global user p '<a-!>xsel -ob<ret>'
map -docstring 'insert from system clipboard' \
  global user P '!xsel -ob<ret>'
