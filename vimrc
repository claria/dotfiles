" Vim Modus statt Vi Modus verwenden
set nocompatible

" Backspace im Einfüge-Modus erlauben
set backspace=indent,eol,start
" Colorscheme
"
set background=dark
colorscheme desert

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Use X Clipboard
if has('unnamedplus')
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

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
set cursorline

" Height of the command bar
set cmdheight=2

" Zeilennummern anzeigen
set number

" öffnende und schließende Klammern hervorheben
set showmatch

" Kommandos beim Eintippen rechts unten in der Statuszeile anzeigen
set showcmd

" Show Tabs and trailing spaces
:set listchars=tab:>-,trail:~,extends:>,precedes:<
:set list
nmap <silent> <leader>s :set nolist!<CR>

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


" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
"set expandtab

" Be smart when using tabs ;)
"set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indnt
set wrap "Wrap lines

:autocmd BufReadPost * :DetectIndent
" set tw=79
"set textwidth=80
:set colorcolumn=80,81
hi ColorColumn guibg=gray25 ctermbg=8

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
