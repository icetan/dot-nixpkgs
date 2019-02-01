hook global WinSetOption filetype=json %{
  set window formatcmd 'jq .'
}
