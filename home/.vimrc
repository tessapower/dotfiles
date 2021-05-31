" vim: set foldmethod=marker foldlevel=0 nomodeline:
" ============================================================================
" .vimrc for Tessa Power {{{
" ============================================================================
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================
" Vim 8 defaults
unlet! skip_defaults_vim
silent! source $VIMRUNTIME/defaults.vim

set clipboard=unnamed         " Set clipboard to unnamed to access sysmte clipboard
set ai                        " Auto indenting
set cc=80                     " Display a ruler at 80 char
set wrap				              " Always wrap lines
set textwidth=79			        " Wrap after 79 characters
set ts=2				              " Tab stop
set sw=2				              " Shift width
set expandtab				          " Replace tabs with spaces
set noshiftround			        " ???
syntax on				              " Turn on syntax highlighting
set nu rnu				            " Turn on hybrid line numbers
set ruler				              " Show file stats
set vb					              " Blink cursor on error instead of beeping (grr)
set encoding=utf-8		        " Encoding
set listchars=tab:▸\ ,eol:¬		" Visualise tabs and newlines

" Status Bar
set laststatus=2

" Searching
set hlsearch
set showmatch

" Nord Theme Overrides and Customisations
augroup nord-theme-overrides
  autocmd!
  " Use 'nord7' for comments
  autocmd ColorScheme nord highlight Comment ctermfg=14 guifg=#8fbcbb
augroup END

" Active Cursor Line Number Background
let g:nord_cursor_line_number_background = 1

" Solid Vertical Split
let g:nord_bold_vertical_split_line = 1

" Uniform Background for Vim Diffs
let g:nord_uniform_diff_background = 1

" Italic Comments
let g:nord_italic_comments = 1

" }}}
" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================
" run PlugInstall to install new plugins after saving

" Specify a directory for plugins
call plug#begin('~/.vim/plugged')

" Nord Theme
Plug 'arcticicestudio/nord-vim'

" Autocompletion for C and C++
" Plug 'xavierd/clang_complete'
" g:clang_library_path='/usr/lib/llvm-10/lib/'

" Emoji Support
Plug 'junegunn/vim-emoji'
  command! -range EmojiReplace <line1>,<line2>s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g

" Vim Language Support
Plug 'sheerun/vim-polyglot'

Plug 'junegunn/goyo.vim'
" Not working properly
" Plug 'junegunn/limelight.vim'
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ }

" Vim tree
Plug 'preservim/nerdtree'

" Vim minimal status line
Plug 'itchyny/lightline.vim'
if !has('gui_running')
  set t_Co=256
endif
set noshowmode

" Rainbow Parentheses
Plug 'frazrepo/vim-rainbow'
au FileType c, cpp call rainbow#load()

" Cute icons
Plug 'ryanoasis/vim-devicons'

" Initialize plugin system
call plug#end()

" }}}

" Color Scheme
colorscheme nord		" Set colorscheme to Nord

