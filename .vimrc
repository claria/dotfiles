" Vim Modus statt Vi Modus verwenden
set nocompatible

" Backspace im Einfüge-Modus erlauben
set backspace=indent,eol,start
" Colorscheme
"
set background=dark
colorscheme desert

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'
Bundle 'Valloric/YouCompleteMe'
Bundle 'tomtom/tcomment_vim'
Bundle 'scrooloose/nerdtree'

autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

let g:ycm_global_ycm_extra_conf = '/home/aem/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
nmap <leader>gh :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Use X Clipboard
set clipboard=unnamed
"if has('unnamedplus')
    "set clipboard=unnamedplus
"else
    "set clipboard=unnamed
"endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac



" Erkennung des Dateityps aktivieren
filetype plugin on

" Indenting anhand des Dateityps aktivieren
filetype indent on

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

" Vim Windows Title xterm
set title

"enable line wrap at begin of line
set whichwrap+=<,>,h,l,[,]

"Neccessary for Latex suite
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'

set mouse=a

" Backup Files in ~/.vim/backups erstellen und Dateiendung .bak anfügen
set backup
set backupdir=~/.backups
set backupext=.bak

" History des Kommandozeilen-Eingaben auf die letzten 1000 beschränken
set history=1000

" Position des Cursors in der Statusleiste anzeigen und aktuelle Zeile einfärben
set ruler
"set cursorline

" Height of the command bar
set cmdheight=2

" Zeilennummern anzeigen
set number

" öffnende und schließende Klammern hervorheben
set showmatch

" Kommandos beim Eintippen rechts unten in der Statuszeile anzeigen
set showcmd

" Show Tabs and trailing spaces
":set listchars=tab:>-,trail:~,extends:>,precedes:<
set listchars=tab:▸\ ,trail:·
:set list
map <silent> <leader>s :set nolist!<CR>

" inkrementelle Suche aktivieren, Groß-/Kleinschreibung bei der Suche
" ignorieren und Suchergebnisse einfärben

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Syntax highlighting aktivieren
syntax on

if v:version > 702
    set undofile
    set undodir=~/.vim/undo      " keep undo history accross sessions
    set undolevels=1000
    set undoreload=10000
endif

" Useful mappings for managing tabs
nnoremap t0  :tabfirst<CR>
nnoremap tl  :tabnext<CR>
nnoremap th  :tabprev<CR>
nnoremap t$  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnew<CR>
nnoremap tm  :tabmove<Space>
nnoremap tq  :tabclose<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
"set expandtab

" Be smart when using tabs ;)
"set smarttab

" 1 tab == 4 spaces
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
"set si "Smart indnt
set nowrap "Wrap lines

":autocmd BufReadPost * :DetectIndent
" set tw=79
"set textwidth=80
if exists('+colorcolumn')
    set colorcolumn=80,81
    hi ColorColumn guibg=gray25 ctermbg=8
endif

"Replace selected text with <C-r>
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction
