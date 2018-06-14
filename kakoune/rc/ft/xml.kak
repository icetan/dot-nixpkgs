hook global WinSetOption filetype=xml %{
  set window formatcmd 'xmllint --output /dev/stdout /dev/stdin'
}
