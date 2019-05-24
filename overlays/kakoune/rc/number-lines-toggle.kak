decl -hidden int number_lines_toggle 0

def number-lines-toggle -docstring 'number-lines-toggle: toggle line number gutter' \
%{ eval %sh{
  if test "${kak_opt_number_lines_toggle}" = 0; then
    printf %s\\n "
      add-highlighter global/ number-lines
      set buffer number_lines_toggle 1
    "
  else
    printf %s\\n "
      remove-highlighter global/number-lines
      set buffer number_lines_toggle 0
    "
  fi
}}

map -docstring 'toggle line number gutter' \
  global user n :number-lines-toggle<ret>
