def linenr -docstring 'linenr <line number>: move cursor to line' \
-params 1 %{ select "%arg{1}.1,%arg{1}.1" }

map -docstring 'move cursor to line' \
  global user : :linenr<space>
