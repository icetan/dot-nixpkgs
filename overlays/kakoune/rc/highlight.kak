add-highlighter shared/tabs regex \t+ 0:default,blue

#add-highlighter shared/non_breaking_spaces regex \s+ 0:Error

add-highlighter shared/trailing_white_spaces regex \h+$ 0:Error

add-highlighter shared/margin regex ^[^\n]{80}([^\n]) 1:+r #column 81 +r

hook global ModeChange .*:insert %{
  remove-highlighter window/tabs
  remove-highlighter window/trailing_white_spaces
}

hook global ModeChange insert:.* %{
  add-highlighter window/tabs ref tabs
  add-highlighter window/trailing_white_spaces ref trailing_white_spaces
}

hook global WinCreate .* %{
  add-highlighter window/wrap wrap
  add-highlighter window/margin ref margin
}

hook global WinSetOption filetype=mu %{
  remove-highlighter window/wrap
  remove-highlighter window/margin
}
