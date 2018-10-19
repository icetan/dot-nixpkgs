# This file is copied from the https://github.com/mawww/kakoune/blob/master/rc/core/grep.kak
decl -docstring "shell command run to search for subtext in a file/directory" \
    str mucmd 'mu find -s d --reverse -f g|s|f|d|%l|'
decl -docstring "name of the client in which utilities display information" \
    str toolsclient
decl -hidden int mu_current_line 0

def -params .. \
  -docstring %{mu [<arguments>]: mu utility wrapper
All the optional arguments are forwarded to the mu utility} \
mu %{ eval %sh{
    alias linebuf='stdbuf -eL -oL'
    output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-mu.XXXXXXXX)/fifo
    mkfifo ${output}
    #if [ $# -gt 0 ]; then
    ( ${kak_opt_mucmd} "${@:-}" \
    | linebuf tr -d \\n \
    | xargs -n5 -d '|' printf '[%-4s] %-60s %-40s %s %s\n' \
    > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
    # -c ${kak_window_width}
    #else
    #    ( ${kak_opt_mucmd} "${kak_selection}" | column -t -s '|' > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
    #fi

    printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
      edit! -fifo ${output} *mu*
      set buffer filetype mu
      set buffer mu_current_line 0
      hook -group fifo buffer BufCloseFifo .* %{
         nop %sh{ rm -r $(dirname ${output}) }
         remove-hooks buffer fifo
      }
    }"
}}


hook -group mu-highlight global WinSetOption filetype=mu %{
    add-highlighter window/mu regex "^\[(.+?)\]" 1:cyan
    add-highlighter window/mu line %{%opt{mu_current_line}} default+b
}

hook global WinSetOption filetype=mu %{
    hook buffer -group mu-hooks NormalKey <ret> mu-jump
    remove-highlighter wrap
}

hook -group mu-highlight global WinSetOption filetype=(?!mu).* %{ remove-highlighter window/mu }

hook global WinSetOption filetype=(?!mu).* %{
    remove-hooks buffer mu-hooks
}

decl -docstring "name of the client in which all source code jumps will be executed" \
    str jumpclient

def -hidden mu-jump %{
    eval %{
        try %{
            exec '<a-x>s[^%]+$<ret>gh'
            set buffer mu_current_line %val{cursor_line}
            eval -try-client %opt{jumpclient} %{ mu-view %reg{0} }
            try %{ focus %opt{jumpclient} }
        }
    }
}

#def mu-next-match -docstring 'Jump to the next mu match' %{
#    eval -collapse-jumps -try-client %opt{jumpclient} %{
#        buffer '*mu*'
#        # First jump to enf of buffer so that if mu_current_line == 0
#        # 0g<a-l> will be a no-op and we'll jump to the first result.
#        # Yeah, thats ugly...
#        exec "ge %opt{mu_current_line}g<a-l> /^[^:]+:\d+:<ret>"
#        mu-jump
#    }
#    try %{ eval -client %opt{toolsclient} %{ exec gg %opt{mu_current_line}g } }
#}
#
#def mu-previous-match -docstring 'Jump to the previous mu match' %{
#    eval -collapse-jumps -try-client %opt{jumpclient} %{
#        buffer '*mu*'
#        # See comment in mu-next-match
#        exec "ge %opt{mu_current_line}g<a-h> <a-/>^[^:]+:\d+:<ret>"
#        mu-jump
#    }
#    try %{ eval -client %opt{toolsclient} %{ exec gg %opt{mu_current_line}g } }
#

decl -docstring "shell command run to view an e-mail" \
    str muviewcmd 'mu view'

def -params .. -file-completion \
    -docstring %{mu-view <msgfile>: view an e-mail} \
mu-view %{ eval %sh{
  outdir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-mu.XXXXXXXX)
  partdir=${outdir}/parts
  output=${outdir}/out

  parts="$(mu extract "${1}" | tail -n+2 | cut -d ' ' -f 3,5 | sed -En 's|^([0-9]+) (\w+)/(\w+)$|\1 \2/\3 \1 \1 \2/\3|p')"
  parts="$(echo "$parts" | sed '/text\/html$/s/^/0000 /;/text\/html$/!s/^/9999 /' | sort | cut -d' ' -f3-)"
  maps="$(echo "${parts}" | xargs -n4 printf "map -docstring \"%s\" buffer user %s \":mu-view '${1}' %s %s<ret>\"\n")"

  if test "${2}"; then
    part=${2}
    form=${3:-text/html}
  else
    part=$(echo "${parts}" | head -n1 | cut -d' ' -f2)
    form=$(echo "${parts}" | head -n1 | cut -d' ' -f4)
  fi

  mkdir -p ${partdir}
  mu extract --parts=${part} --target-dir ${partdir} "${1}"
  ((
    mu view --summary-len=1 "${1}" | head -n-1
    echo
    mail-view "${form}" ${partdir}/*
  ) > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null

  printf %s\\n "eval -try-client '$kak_opt_toolsclient' %{
    edit! -existing ${output}
    set buffer filetype mail
    remove-highlighter wrap
    ${maps}
    hook -group muview buffer BufClose .* %{
      nop %sh{ rm -r ${outdir} }
      remove-hooks buffer muview
    }
  }"
}}

def mu-cfind -docstring 'mu-cfind <contact>: ' \
  -params 1 -shell-script-candidates %{ mu cfind --format=csv | sed 's/,/ </;s/$/>/' } %{
  reg '"' %arg{1}
  exec '!printf %s "$kak_reg_dquote"<ret>'
}
