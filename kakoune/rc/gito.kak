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

def -docstring %{gito-enable: enable gito sync for this buffer} \
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

def -docstring %{gito-enable: disable gito sync for this buffer} \
gito-disable %{
  autosave-disable
  set buffer autoreload ask
  remove-hooks buffer gito
  remove-hooks global gito
}
