def -docstring %{autosave-enable: enable autosave for this file buffer} \
autosave-enable %{ %sh{
  [ "${kak_buffile}" ] \
    && printf %s\\n 'hook -group autosave buffer NormalIdle .* %{ %sh{
      [ "${kak_modified}" == "true" ] && echo "exec -save-regs : :w<ret>"
    }}'
}}

def -docstring %{autosave-enable: disable autosave for this file buffer} \
autosave-disable %{
  remove-hooks buffer autosave
}

def -docstring %{gito-sync: gito sync this buffer} \
gito-sync %{ %sh{
  ( gito sync "${kak_buffile}" 2>&1 ) > /dev/null 2>&1 < /dev/null &
}}

decl -docstring "name of the client in which utilities display information" \
    str toolsclient
def -docstring %{gito-listen: start a gito listener in current directory} \
gito-listen %{ %sh{
    output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-gito.XXXXXXXX)/fifo
    mkfifo ${output}
    ( gito listen > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &

    printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
      edit! -fifo ${output} *gito*
      set buffer filetype log
      hook -group fifo buffer BufCloseFifo .* %{
         nop %sh{ rm -r $(dirname ${output}) }
         remove-hooks buffer fifo
      }
    }"
}}

def -docstring %{gito-enable: enable gito sync} \
gito-enable %{
  hook -group gito global BufCreate .* %{ %sh{
    [ "${kak_buffile}" ] && gito gitopath -q "${kak_buffile}" \
      && printf %s\\n 'eval %{
        autosave-enable
        set buffer autoreload yes
        hook -group gito buffer BufWritePost .* gito-sync
      }'
  }}
}

def -docstring %{gito-enable: disable gito sync} \
gito-disable %{
  autosave-disable
  set buffer autoreload ask
  remove-hooks buffer gito
  remove-hooks global gito
}
