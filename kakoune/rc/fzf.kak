def fzf -docstring 'fzf <file path>: edit a file' \
-params 1 -shell-candidates %{ find * -type f ! -path '.git/*' | head -n10000 } %{ edit %arg{1} }

map -docstring 'fuzzy file' \
  global user f :fzf<space>

map -docstring 'fuzzy buffer' \
  global user b :b<space>
