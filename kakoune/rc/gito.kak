hook global BufWritePost .* %{ %sh{
  ( gito sync 2>&1 ) > /dev/null 2>&1 < /dev/null &
} }

hook global NormalIdle .* %{ %sh{
  [[ "${kak_buffile}" && "${kak_modified}" == "true" ]] && echo 'exec :w<ret>'
} }
