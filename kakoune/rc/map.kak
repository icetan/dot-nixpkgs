#map global normal <space> ,
#map global user <space> <space>

# User mappings
map -docstring 'quit' \
  global user q :quit<ret>
map -docstring 'delete buffer' \
  global user d :db<ret>
map -docstring 'delete buffer!' \
  global user D :db!<ret>
map -docstring 'split horizontally' \
  global user s :tmux-new-horizontal<ret>
map -docstring 'split vertically' \
  global user v :tmux-new-vertical<ret>
map -docstring 'format buffer' \
  global user = :format<ret>

# Case insensitive search
map -docstring 'case insensitive search' \
  global normal '/' /(?i)
map -docstring 'case insensitive backward search' \
  global normal '<a-/>' <a-/>(?i)
map -docstring 'case insensitive extend search' \
  global normal '?' ?(?i)
map -docstring 'case insensitive backward extend-search' \
  global normal '<a-?>' <a-?>(?i)

# Select inner/surrounding object
map -docstring 'select anglebraces both ways' \
  global object A c<lt>|>,<lt>|><ret>
