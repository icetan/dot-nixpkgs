def -hidden surround-key %{
  info -title 'surround with' %{b,(,):  parenthesis block
B,{,}: braces block
r,[,]: brackets block
a,<lt>,<gt>: angle block
",Q: double quote string
',q: single quote string
`,g: grave quote string
<space>: space
c: custom
d,<del>,<backspace>: delete}
  on-key %{ exec %sh{
    code=0
    case $kak_key in
      'b'|'('|')')               first='(' last=')';;
      'B'|'{'|'}')               first='{' last='}';;
      'r'|'['|']')               first='[' last=']';;
      'a'|'<lt>'|'<gt>')         first='<lt>lt<gt>' last='<lt>gt<gt>';;
      '"'|'Q')                   first='"' last='"';;
      "'"|'q')                   first="''" last="''";;
      '`'|'g')                   first='`' last='`';;
      '<space>')                 first=' ' last=' ';;
      'c')                       code=2;;
      'd'|'<del>'|'<backspace>') code=3;;
      *)                         code=9;;
    esac

    case $code in
      0) echo ":surround '$first' '$last'<ret>";;
      2) echo ":surround ";;
      3) echo "i<backspace><esc>a<del><esc>";;
      *) echo "<esc>";;
    esac
  }}
}

def -params 1..2 \
  -docstring %{surround <before> [<after>]: Add <before> before selections
If <after> is provided: add <after> after selections
else: add <before> after selections} \
surround %{ exec -draft %sh{
  printf '%s' "<Z>i$1<esc>a${2-$1}<esc><z>"
}}

map global user S ":surround-key<ret>" -docstring "surround selection"
