" Remove runtime paths not loaded from the nix store, doesn't support remote
" plugins.
"let &rtp=join(filter(split(&rtp, ','), 'v:val=~"^/nix/store/"'), ',')

" Theme
colorscheme solo
" UTF-8
scriptencoding utf-8
set encoding=utf-8
set nobomb
" Buffers
set hidden
" Search
set gdefault                          " Global search by default (/g turns it off).
set hlsearch                          " Highlight results.
set incsearch                         " Search-as-you-type.
set ignorecase                        " Case-insensitive…
set smartcase                         " …unless phrase includes uppercase.
" UI
set cursorline
set fillchars=vert:\                  " No pipes in vertical split separators.
set listchars=nbsp:·,extends:»,tab:▸·,trail:·
set list!                             " Show invisibles.
set showcmd                           " Show partially typed command sequences.
set laststatus=2                      " Always show status bar.
set ruler                             " Show line, column and scroll info in status line.
"set textwidth=80                      " Automatically wrap lines when inserting.
set wrap                              " Wrap lines.
set linebreak
set showbreak=↵                       " Line wrap char.
set visualbell                        " Don't beep.
set modelines=1                       " Use modeline overrides.
set scrolloff=3                       " Minimum number of lines to always show above/below the caret.
set noshowmode                        " Hide mode.
set nofoldenable                      " Disable fold on open file
" Editing
set backspace=indent,eol,start        " Allow backspacing over everything in insert mode.
set nojoinspaces                      " 1 space, not 2, when joining sentences.
" Auto indenting
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set autoindent
set smarttab
" Remove backup files
set nobackup
set noswapfile
set nowritebackup
" Autoread file on change
"set autoread
" Always forward slashes
set shellslash
" Don't print stuff from shell
set shellpipe=2>&1>
" Save editor state to ~/.viminfo
set viminfo=%,!,'50,\"100,:100,n~/.viminfo
" Use mouse in terminal
set mouse=a
set mousemodel=extend
" No timeout for ESC
set timeoutlen=1000 ttimeoutlen=0
" Look for ctags up the dir tree
set tags=tags;/

" Files to ignore
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*

" Easy motion
map \ <Plug>(easymotion-prefix)
" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
 " type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1

let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode

let g:lightline = {
      \ 'colorscheme': '16color',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'filename', 'ctrlpmark'] ],
      \   'right': [ [ 'errors', 'lineinfo' ], ['percent'], [ 'fileformat', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filepath' ] ],
      \   'right': [ [ 'errors', 'lineinfo' ], ['percent'] ]
      \ },
      \ 'component_function': {
      \   'filename': 'MyFilename',
      \   'filepath': 'MyFilePath',
      \   'fileformat': 'MyFileformat',
      \   'filetype': 'MyFiletype',
      \   'mode': 'MyMode',
      \   'ctrlpmark': 'CtrlPMark'
      \ },
      \ 'component_expand': {
      \   'errors': 'MyErrors',
      \ },
      \ 'component_type': {
      \   'errors': 'error',
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

function! MyModified()
  return &ft =~ 'help' ? "" : &modified ? '+' : &modifiable ? "" : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help' && &readonly ? 'RO' : ""
endfunction

function! MyFilename()
  let fname = expand('%:t')
  "\   ? (winwidth(0) > strlen(expand('%')) ? expand('%') : fname)
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ ("" != MyReadonly() ? MyReadonly() . ' ' : "") .
        \ ("" != fname
        \   ? fname
        \   : '[No Name]'
        \ ) .
        \ ("" != MyModified() ? ' ' . MyModified() : "")
endfunction

function! MyFilePath()
  let fname = expand('%')
  return ("" != MyReadonly() ? MyReadonly() . ' ' : "") .
        \ ("" != fname ? fname : '[No Name]' ) .
        \ ("" != MyModified() ? ' ' . MyModified() : "")
endfunction

function! MyFileformat()
  return winwidth(0) > 80 ? &fileformat . ':' . (strlen(&fenc) ? &fenc : &enc) : ""
endfunction

function! MyFiletype()
  return winwidth(0) > 80 ? (strlen(&filetype) ? &filetype : 'no ft') : ""
endfunction

function! MyMode()
  let fname = expand('%:t') == 'ControlP' ? 'CtrlP' : lightline#mode()
  return winwidth(0) > 80 ? fname : split(fname, '.\zs')[0]
endfunction

function! MyErrors()
  return winwidth(0) > 20 && !empty(SyntasticStatuslineFlag()) ? '▲' : ""
endfunction

function! CtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ""
  endif
endfunction

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

"" Margin line same value as textwidth
"set colorcolumn=+0
"hi ColorColumn ctermbg=lightgrey guibg=lightgrey
set colorcolumn=80

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"exec 'match ErrorMsg /\\%>' . &colorcolumn . 'v.\\+/'

" Persistent undo
set undofile
set undodir=~/.vimundo " Need to create this directory for undofile to work
" Key mappings
let mapleader = ","

set pastetoggle=<F4>

" Clear highlights
map <F3> :let @/=""<CR>

" Close current buffer
map <C-W>d :bn\|bd #<CR>

" Create an empty buffer in verical split window
map <C-W>n :vert new<CR>

" Ctrl-h same as split horizontally
noremap <C-W>h <C-W>s
" Ctrl-x same as close window
map <C-W>x <C-W>c

" Open current buffer in new tab, hack for tmux like zoom feature
noremap <C-W>z :tab split<CR>

" Simplified window navigation
" XXX: Hack for neovim, Ctrl-H is interpreted as a backspace
" https://github.com/neovim/neovim/issues/2048
if has('nvim')
  "nnoremap <BS> <C-W>h
  nnoremap <bs> :<c-u>TmuxNavigateLeft<cr>
else
  nnoremap <C-H> <C-W>h
endif
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
"nmap - <C-W>-
nmap + <C-W>+

" Make Y consistent with C and D - yank to end of line, not full line.
nnoremap Y y$

" Don't save overwriten text into default register when pasting in visual
" mode.
vnoremap p "_dP

" Tab/shift-tab to indent/outdent in visual mode.
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Keep selection when indenting/outdenting.
vnoremap > >gv
vnoremap < <gv

" CtrlP
"if has('python')
"  let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
"endif
let g:ctrlp_match_func = { 'match': 'matcher#cmatch' }

let g:ctrlp_show_hidden = 1

" CtrlP mappings
map <C-Y>  :CtrlPYankRound<CR>
map <C-T>f :CtrlPCurFile<CR>
map <C-T>m :CtrlPMRUFiles<CR>
map <C-T>d :CtrlPDir<CR>
map <C-T>b :CtrlPBuffer<CR>
map <C-T>o :CtrlPBookmarkDir<CR>
map <C-T>a :CtrlPBookmarkDirAdd<CR>
map <C-T>r :CtrlPClearCache<CR>
map <C-T>t :CtrlPBufTag<CR>
map <C-T>q :CtrlPQuickfix<CR>

" Java formating
au FileType java setlocal sw=4 sts=4 ts=4
              \| setlocal colorcolumn=100

" Ensime (Scala / Java)
au FileType scala,java nnoremap <buffer> <silent> [g :EnDeclaration<CR>
                    \| nnoremap <buffer> <silent> ]g :EnSearch <C-R><C-W><CR>
                    \| nnoremap <buffer> <silent> <leader>t :EnType<CR>
                    \| nnoremap <buffer> <silent> <leader>T :EnTypeCheck<CR>

" Make CSS class and id names include `-`
au FileType html,css,less,scss setl isk+=-

au BufRead,BufNewFile *.md,*.markdown set ft=markdown
let g:markdown_fenced_languages = ['html', 'xml', 'python', 'sh', 'bash=sh', 'json']
au BufRead,BufNewFile *.jira,*.confluence set ft=confluencewiki

command! -nargs=+ Silent execute 'silent <args>'

" TODO: Convert to plugin
" Nicer grep
function! GrepFunc(...)
  let exfiles = split(&wildignore, ',')
  let exdirs = map(filter(copy(exfiles), "v:val=~'\\/\\*\\?''$'"), "substitute(v:val, '\\/\\*\\?''$', \"\", 'g')")
  call filter(exfiles, "v:val!~'\\/\\*\\?''$'")
  let args_ = '-I '
  if len(exfiles) | let args_ .= '--exclude={'.join(exfiles, ',').'} ' | endif
  if len(exdirs) | let args_ .= '--exclude-dir={'.join(exdirs,',').'} ' | endif
  let args_ .= join(a:000, ' ')
  "if (empty(v:servername))
    exe 'Silent grep! ' . args_
    copen
  "else
  "  exe 'AsyncGrep ' . args_
  "  echo 'Greping...'
  "endif
endfunction

function! GrepirSelection()
  call GrepFunc('-iR "'.substitute(substitute(@/, '^\\<', '\\b', ""), '\\>''$', '\\b', "").'" .')
endfunction

command -nargs=+ Grep   call GrepFunc(<f-args>)
command -nargs=+ Grepi  execute 'Grep -i <args>'
command -nargs=+ Grepr  execute 'Grep -R <args>'
command -nargs=+ Grepir execute 'Grep -iR <args>'
nnoremap <silent><leader>f :call GrepirSelection()<CR>

let g:localvimrc_persistent = 1

" TODO: Convert netrw's gitignore list from regex to glob which is the format
" of wildignore.
autocmd VimEnter * let &wildignore = &wildignore . ',' . netrw_gitignore#Hide()
