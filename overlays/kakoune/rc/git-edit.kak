def -docstring '' \
  git-edit -params 1 -shell-script-candidates %{ git ls-files; git ls-files --others --exclude-standard } %{ edit %arg{1} }

alias global ge git-edit

map -docstring 'fuzzy git ls-files' \
  global user F :git-edit<space>
