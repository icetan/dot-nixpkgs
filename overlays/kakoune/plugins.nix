{ writeText, fetchgit, rtrav, src-block, lib, ripgrep, kak-lsp }: let
  inherit (builtins) readFile fromJSON elem;
  inherit (lib) filterAttrs;

  deps = fromJSON (readFile ./deps.json);
  fetch = src: fetchgit { inherit (src) url rev sha256 fetchSubmodules; };

  inherit (deps)
    #easymotion-src
    ecmascript-src
    eslint-formatter-src
    flow-src
    cd-src
    typescript-src;
in [
#  (writeText "easymotion.kak" ''
#    source ${fetch easymotion-src}/easymotion.kak
#    map -docstring 'easymotion word' \
#      global user w :easy-motion-word<ret>
#    map -docstring 'easymotion WORD' \
#      global user W :easy-motion-WORD<ret>
#    map -docstring 'easymotion line' \
#      global user l :easy-motion-line<ret>
#  '')

#  set window lintcmd '$eslint --format=${eslint-formatter-src}'
#  (writeText "ecmascript.kak" ''
#    source ${fetch ecmascript-src}/ecmascript.kak
#
#    hook global WinSetOption filetype=ecmascript %{
#      #set window formatcmd 'prettier --stdin --semi false --single-quote --jsx-bracket-same-line --trailing-comma all'
#
#      eval %{ %sh{
#        eslint="`${rtrav}/bin/rtrav node_modules/.bin/eslint $PWD && printf %s /node_modules/.bin/eslint || printf %s eslint`"
#        tmpfile="`dirname $kak_val_buffile || echo $PWD`/__tmp.js"
#        printf %s "
#          set window formatcmd 'cat > $tmpfile; $eslint --fix $tmpfile 2>&1 > /dev/null; cat $tmpfile; rm $tmpfile'
#        ";
#      }}
#      lint-enable
#    }
#  '')

#  (writeText "flow.kak" ''
#    source ${fetch flow-src}/flow.kak
#  '')

  (writeText "cd.kak" ''
    source ${fetch cd-src}/cd.kak

    # Suggested aliases
    alias global cdd change-directory-current-buffer
    alias global cdr change-directory-project-root
    alias global pwd print-working-directory
    alias global ecd edit-current-buffer-directory

    # Suggested mappings
    map global goto d '<esc>:change-directory-current-buffer<ret>' -docstring 'current buffer dir'
    map global goto r '<esc>:change-directory-project-root<ret>' -docstring 'project root dir'
    map global user e ':edit-current-buffer-directory<ret>' -docstring 'edit in current buffer dir'
  '')

  (writeText "ripgrep.kak" ''
    set global grepcmd '${ripgrep}/bin/rg --column'
  '')

  (writeText "src-block.kak" ''
    map global user '[' '|SB_STYLE=''${kak_buffile##*.} ${src-block}/bin/src-block<ret>' -docstring 'expand source blocks'
    map global user ']' '|SB_STYLE=''${kak_buffile##*.} ${src-block}/bin/src-block -d<ret>' -docstring 'unexpand source blocks'
  '')

  (writeText "kak-lsp.kak" ''
    eval %sh{${kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}

    # Start debug logging
    # (removing this stops javacs from working for some reason)
    nop %sh{ (${kak-lsp}/bin/kak-lsp -s $kak_session -vvv ) > /tmp/kak-lsp.$kak_session.log 2>&1 < /dev/null & }
  '')
]
