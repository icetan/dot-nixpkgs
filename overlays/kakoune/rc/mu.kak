# This file is copied from the https://github.com/mawww/kakoune/blob/master/rc/core/grep.kak
decl -docstring "shell command run to search for subtext in a file/directory" \
    str mucmd 'mu find -s d --reverse -f g|||d|||f|||s|||%l'
decl -docstring "name of the client in which utilities display information" \
    str toolsclient
decl -hidden int mu_current_line 0

def -params .. \
  -docstring %{mu [<arguments>]: mu utility wrapper
All the optional arguments are forwarded to the mu utility} \
mu %{ evaluate-commands %sh{
    alias linebuf='stdbuf -eL -oL'

    output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-mu.XXXXXXXX)/fifo
    mkfifo ${output}

    ( ${kak_opt_mucmd} "${@:-}" \
      | linebuf sed 's/\(.*\)|||\(.*\)|||\(.*\)|||\(.*\)|||\(.*\)/\1\n\2\n\3\n\4\n\5/g' \
      | linebuf tr '\n' '\0' \
      | xargs -0 -L5 printf '[%-5s] %-35s %-50s %-100s %s\n' \
      > ${output} 2>&1 &
    ) > /dev/null 2>&1 < /dev/null

    printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
      edit! -fifo ${output} *mu*
      set buffer filetype mu
      set buffer mu_current_line 0
      hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) } }
    }"
}}


hook -group mu-highlight global WinSetOption filetype=mu %{
    add-highlighter window/mu group
    add-highlighter window/mu/ regex "^\[(.+?)\] (.+? CES?T)  +((?:[^ ]+? )+<[^@]+@.+?>|[^@]+@[^ ]+?) (.+?) (%%/.+?)$" 1:red 2:magenta 3:cyan 4:green 5:black
    add-highlighter window/mu/ line %{%opt{mu_current_line}} default+b
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/mu }
}

hook global WinSetOption filetype=mu %{
    hook buffer -group mu-hooks NormalKey <ret> mu-jump
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks buffer mu-hooks }
}

hook -group mu-highlight global WinSetOption filetype=(?!mu).* %{ remove-highlighter window/mu }

hook global WinSetOption filetype=(?!mu).* %{
    remove-hooks buffer mu-hooks
}

decl -docstring "name of the client in which all source code jumps will be executed" \
    str jumpclient

def -hidden mu-jump %{
    evaluate-commands %{
        try %{
            exec '<a-x>s^\[([^\] ]+) *\][^%]+%([^%]+)$<ret>gh'
            set buffer mu_current_line %val{cursor_line}
            evaluate-commands -try-client %opt{jumpclient} -verbatim -- mu-view %reg{1} %reg{2}
            try %{ focus %opt{jumpclient} }
        }
    }
}

#def mu-next-match -docstring 'Jump to the next mu match' %{
#    evaluate-commands -collapse-jumps -try-client %opt{jumpclient} %{
#        buffer '*mu*'
#        # First jump to enf of buffer so that if mu_current_line == 0
#        # 0g<a-l> will be a no-op and we'll jump to the first result.
#        # Yeah, thats ugly...
#        exec "ge %opt{mu_current_line}g<a-l> /^[^:]+:\d+:<ret>"
#        mu-jump
#    }
#    try %{ evaluate-commands -client %opt{toolsclient} %{ exec gg %opt{mu_current_line}g } }
#}
#
#def mu-previous-match -docstring 'Jump to the previous mu match' %{
#    evaluate-commands -collapse-jumps -try-client %opt{jumpclient} %{
#        buffer '*mu*'
#        # See comment in mu-next-match
#        exec "ge %opt{mu_current_line}g<a-h> <a-/>^[^:]+:\d+:<ret>"
#        mu-jump
#    }
#    try %{ evaluate-commands -client %opt{toolsclient} %{ exec gg %opt{mu_current_line}g } }
#

decl -docstring "shell command run to view an e-mail" \
    str muviewcmd 'mu view'

def -params 1 -file-completion \
    -docstring %{mu-view-gui <msgfile>: view an e-mail via xdg-open} \
mu-view-gui %{ nop %sh{
  (nohup xdg-open "$1") > /dev/null 2>&1 < /dev/null &
}}

def -params .. -file-completion \
    -docstring %{mu-view <msgflags> <msgfile>: view an e-mail} \
mu-view %{ evaluate-commands %sh{
  msg="$2"
  outdir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-mu.XXXXXXXX)
  output="$outdir/out"
  partdir="$outdir/parts"
  head=$(mu view --summary-len=1 "$msg" | head -n-1)

  if { echo "$1" | grep -q x; }; then
    mkdir -p "$partdir"
    mu extract --save-all --target-dir "$partdir" "$msg"
    decryptdir="$outdir/decrypted"
    mkdir -p "$decryptdir"
    msg_=$(echo $partdir/${3:-*}.msgpart | awk '{ print $1 }')
    msg="$decryptdir/$(basename $msg_)"
    gpg --decrypt "$msg_" > "$msg"
    rm -r "$partdir"
  fi

  parts=$(mu extract "$msg" | tail -n+2 | awk '{ print $1,$3,$1,$1,$3 }')
  parts=$(echo "$parts" | sed '/text\/html$/s/^/0000 /;/text\/html$/!s/^/9999 /' | sort | cut -d' ' -f3-)
  #maps=$(echo "$parts" | xargs -n4 printf "map -docstring \"%s\" buffer user %s \":mu-view '${1}' '${msg}' %s %s<ret>\"\n")

  if test "$3"; then
    part="$3"
    form="${4:-text/html}"
  else
    part=$(echo "$parts" | head -n1 | awk '{ print $2 }')
    form=$(echo "$parts" | head -n1 | awk '{ print $4 }')
  fi

  mkdir -p "$partdir"
  mu extract --overwrite --parts=$part --target-dir "$partdir" "$msg"
  msgpart=$(echo $partdir/${part:-*}.msgpart | awk '{ print $1 }')
  ((
    echo "$head"
    echo
    mail-view "$form" "" "$msgpart"
  ) > "$output" 2>&1 ) > /dev/null 2>&1 < /dev/null
  cp "$msgpart" "$msgpart.html"

  printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
    edit! -readonly -existing ${output}
    set buffer filetype mail
    remove-highlighter wrap
    ${maps}
    map -docstring \"open in browser\" buffer user o \":mu-view-gui '${msgpart}.html'<ret>\"
    hook -always -once buffer BufClose .* %{ nop %sh{ rm -r ${outdir} } }
  }"
}}

def mu-cfind -docstring 'mu-cfind <contact>: ' \
  -params 1 -shell-script-candidates %{ mu cfind --format=csv | sed 's/,/ </;s/$/>/' } %{
  reg '"' %arg{1}
  exec '!printf %s "$kak_reg_dquote"<ret>'
}
