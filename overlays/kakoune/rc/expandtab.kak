define-command noexpandtab %{
    hook -group noexpandtab global NormalKey <gt> %{
        execute-keys -draft "xs^\h+<ret><a-@>"
    }
    remove-hooks global expandtab
}

define-command expandtab %{
    hook -group expandtab global InsertChar \t %{
        execute-keys -draft h@
    }
    hook -group expandtab global InsertDelete ' ' %{ try %{
        execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    }}
    remove-hooks global noexpandtab
}
