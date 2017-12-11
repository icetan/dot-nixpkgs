hook global NormalKey y|d|c %{ nop %sh{
  printf %s "$kak_reg_dquote" | xsel --input --clipboard
}}

map -docstring 'append from system clipboard' \
  global user p '<a-!>xsel --output --clipboard<ret>'
map -docstring 'insert from system clipboard' \
  global user P '!xsel --output --clipboard<ret>'
