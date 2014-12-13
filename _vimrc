" Vim Pathogen 
runtime bundle/pathgen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

set nocompatible

let g:isWin=(has("win32") || has("win64") || has("win32unix"))

let g:isGUI=has("gui_running")

if g:isWin
    let $vimrc = $VIM . "/_vimrc"
    let $vimfiles = $VIM . "/vimfiles"
else
    let $vimrc = "~/.vimrc"
    let $vimfiles = "~/.vim"
endif

" ������ʱ����ʾ�Ǹ�Ԯ���������ͯ����ʾ
set shortmess=atI

set diffexpr=MyDiff()
function! MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let eq = ''
    if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
            let cmd = '""' . $VIMRUNTIME . '\diff"'
            let eq = '"'
        else
            let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
    else
        let cmd = $VIMRUNTIME . '\diff'
    endif
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

"python�ӿ�

python << EOF_PYTHON

import vim
import sys
import os
import re

#��ʽ�������ļ�
def FormatCode(tp):
    ft = vim.eval('&filetype')
    if ft in ('c', 'cpp', 'java', 'cs'):
        vim.command('normal mx')
        ff = vim.eval('&ff')
        vim.command('set ff=dos') #��unix��β�»���BUG���ĳ�DOS��β
        if tp == 0: #format all code
            vim.command('%!astyle -A1pHcjUnwK -z2 -k1')
        else:
            vim.command("'<,'>!astyle -A1pHcjUnwK -z2 -k1")
        vim.command('set ff=%s' % ff) #�ָ�ԭ������β
        vim.command('normal `x')
    elif ft in ('xml',):
        vim.command('normal mx')
        vim.command(r'''silent! %s/>\(\s*$\)\@!/>\r/g''')
        vim.command(r'''silent! %s/\(^\s*\)\@<!</\r</g''')
        vim.command(r'''normal gg=G''')
        vim.command(r'''silent! %s/\s*$//g''') #ɾ����β�Ŀո�
        vim.command(r'''silent! %m/asd^$(())fajl;''')
        vim.command('normal `x')
    else:
        print >> sys.stderr, "Format code: file type not supported!"

EOF_PYTHON
"==================================================================
"ͨ�õ�����
"
if g:isWin
    set shellslash
    set fencs=ucs-bom,gb2312,utf-8,gbk,big5,gb18030
    if &fenc == "" && &modifiable
        set fenc=gbk
    endif
    set fileformats=dos,unix
    if g:isGUI
        set encoding=utf-8
        set guifont=bitstream_vera_sans_mono:h10
        "set guifontwide=SimHei:h11
        set linespace=3
        "��iconv.dll���Ƶ�gvim.exeͬĿ¼�¿ɽ��UCS-BOM������ļ���ʾ���������
        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim
        language messages zh_CN.utf-8
        if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
            set ambiwidth=double
        endif
        colorscheme desert
    else
        set encoding=gbk
        colorscheme papayawhip
    endif
else
    set fencs=ucs-bom,utf-8,gb18030,big5
    if &fenc == "" && &modifiable
        set fenc=utf-8
    endif
    set encoding=utf-8
    set fileformats=unix,dos
    if g:isGUI
        colorscheme wombat256
    else
        colorscheme default
    endif
endif

if g:isWin
    function! ChangeEUCCNtoGBK()
        if &fenc == "euc-cn" && &modifiable == 1
            set fenc=gbk
        endif
    endfunction
    au BufRead * call ChangeEUCCNtoGBK()
endif

let &termencoding = &encoding

if g:isGUI && !exists("s:has_inited")
    let s:has_inited = 1
    set lines=42 columns=160
endif

" ������buffer���κεط�ʹ����꣨����office���ڹ�����˫����궨λ��
if has('mouse')
    set mouse=a
endif

set guioptions-=T  "To  Remove toolbar   ����ʾ������
set guioptions+=c
set guioptions+=b

"�Ҽ������˵�
set mousemodel=popup

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" �ڱ��ָ�Ĵ��ڼ���ʾ�հף������Ķ�
set fillchars=vert:\ ,stl:\ ,stlnc:\

set sidescroll=20

" ��ǿģʽ�е��������Զ���ɲ���
set wildmenu
" ����backspace�͹�����Խ�б߽�
set whichwrap+=<,>,h,l

set statusline=%{expand('%:p:h')}%{g:isWin?'\\':'/'}%2*%t%1*%m%r%h%w%0*%=\ [%1*%{&ff=='unix'?'\\n':(&ff=='dos'?'\\r\\n':'\\r')},%{&fenc},%{&ft}%0*][%2*%02l,%02v,%04o,0x%04B%0*][%1*%{expand('%')!=''?strftime('%Y-%m-%d\ %H:%M:%S',getftime(expand('%:p'))):'-'}%0*][%2*%P%0*]
" ������ʾ״̬��
set laststatus=2
" �ڱ༭�����У������½���ʾ���λ�õ�״̬��
set ruler

" ͨ��ʹ��: commands������������ļ�����һ�б��ı��
set report=0

set nobackup

set history =1000
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

set diffopt =filler,vertical

set incsearch
set hlsearch

set nu
set nuw=4

set tabstop     =4  " ts, number of spaces a tab in the file counts for
set softtabstop =4  " sts, 
set shiftwidth  =4
set smarttab
set et  " ���������Ҫ�ر�, makefile
autocmd FileType make,tags set noexpandtab

set autoindent
set smartindent
set cindent

set ignorecase smartcase

set colorcolumn=121

set matchpairs =(:),[:],{:},<:>

set foldmethod=indent
" set foldmethod=syntax
set foldlevel=100
set foldopen-=search
set foldopen-=undo
set foldcolumn=4

syntax enable
syntax on
filetype plugin indent on

" ================================ File Types ======================================

" C++
au FileType c,cpp,objc,objcpp set syntax=cpp11 | call CSyntaxAfter()
au BufNewFile,BufRead *
\ if expand('%:e') =~ '^\(h\|hh\|hxx\|hpp\|ii\|ixx\|ipp\|inl\|txx\|tpp\|tpl\|cc\|cxx\|cpp\)$' |
\   if &ft != 'cpp'                                                                           |
\     set ft=cpp                                                                              |
\   endif                                                                                     |
\ endif

" vimprj
au BufNewFile,BufRead *.vimprj set syntax=vim

" miniBuffer
let g:miniBufExplMapCTabSwitchBufs = 1

"�Զ���ʾ
let g:acp_enableAtStartup=1
let g:acp_mappingDriven=1
" let g:acp_behaviorSnipmateLength=1

" SuperTab completion fall-back 
let g:SuperTabDefaultCompletionType='<c-x><c-u><c-p>'
" SuperTab completion fall-back for context aware completion
" (incompatible with g:clang_auto_select=0, using the above)
" let g:SuperTabContextDefaultCompletionType='<c-x><c-u><c-p>'

