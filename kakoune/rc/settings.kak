set global tabstop     2
set global indentwidth 2
set global scrolloff   3,5

hook global WinSetOption filetype=markdown %{
    #hook buffer -group mu-hooks NormalKey <ret> mu-jump
    #remove-highlighter wrap
    autowrap-enable
}

#hook global WinSetOption filetype=(?!mu).* %{
#    remove-hooks buffer mu-hooks
#}
