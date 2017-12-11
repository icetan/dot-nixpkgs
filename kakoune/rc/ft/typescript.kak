hook global BufCreate .*\.(ts) %{
  set buffer filetype javascript
}

# filetypes
#hook global WinSetOption filetype=javascript %{
#  set window lintcmd 'eslint -f ~/.config/kak/eslint-kakoune.js'
#  lint-enable
#}
