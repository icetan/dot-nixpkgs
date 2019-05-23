add-highlighter shared/trailing_white_spaces regex \h+$ 0:Error

add-highlighter shared/margin regex ^[^\n]{80}([^\n]) 1:+r #column 81 +r

hook global ModeChange .*:insert %{
  remove-highlighter window/trailing_white_spaces
}

hook global ModeChange insert:.* %{
  add-highlighter window/trailing_white_spaces ref trailing_white_spaces
}

hook global WinCreate .* %{
  add-highlighter window/wrap   wrap
  add-highlighter window/margin ref margin
}

hook global WinSetOption filetype=mu %{
  remove-highlighter window/wrap
  remove-highlighter window/margin
}

face global Whitespace black
add-highlighter global/ show-whitespaces -tab "▏" -lf " " -nbsp "⋅" -spc " "
