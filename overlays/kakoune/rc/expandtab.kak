define-command noexpandtab %{
    hook -group noexpandtab buffer NormalKey <gt> %{
        execute-keys -draft "xs^\h+<ret><a-@>"
    }
    remove-hooks buffer expandtab
}

define-command expandtab %{
    hook -group expandtab buffer InsertChar \t %{
        execute-keys -draft h@
    }
    hook -group expandtab buffer InsertDelete ' ' %{ try %{
        execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    }}
    remove-hooks buffer noexpandtab
}

# Detect tabs in file and turn of expansion
hook global BufOpenFile .* %{ evaluate-commands -buffer %val(hook_param) %{ try %{
  execute-keys '%s^\t<ret>'
  #set buffer indentwidth 0
  noexpandtab
} catch %{
  expandtab
}}}
