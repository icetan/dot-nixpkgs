hook global WinSetOption filetype=markdown %{
  autowrap-enable
  eval %sh{
    printf %s\\n "set window formatcmd \"fmt -c -w ${kak_opt_autowrap_column}\""
  }
}
