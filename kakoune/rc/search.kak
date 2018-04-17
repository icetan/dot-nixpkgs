face global search +bi

hook global NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
    add-highlighter global dynregex '%reg{/}' 0:search
}}

hook global NormalKey <esc> %{ try %{
    remove-highlighter global/dynregex_%reg{<slash>}
}}
