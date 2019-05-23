set global tabstop     2
set global softtabstop 2 # smarttab.kak
set global indentwidth 2
set global scrolloff   3,5

eval %sh{
  printf %s\\n "set global formatcmd \"fmt -c -w ${kak_opt_autowrap_column}\""
}
