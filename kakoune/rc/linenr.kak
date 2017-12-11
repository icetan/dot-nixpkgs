def linenr -docstring 'linenr <line number>: move cursor to line' \
-params 1 %{ select "%arg{1}.0,%arg{1}.0" }

map -docstring 'move cursor to line' \
  global user : :linenr<space>
