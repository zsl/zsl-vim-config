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

" 启动的时候不显示那个援助索马里儿童的提示
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

"python接口

python << EOF_PYTHON

import vim
import sys
import os
import re

#格式化代码文件
def FormatCode(tp):
    ft = vim.eval('&filetype')
    if ft in ('c', 'cpp', 'java', 'cs'):
        vim.command('normal mx')
        ff = vim.eval('&ff')
        vim.command('set ff=dos') #在unix行尾下会有BUG，改成DOS行尾
        if tp == 0: #format all code
            vim.command('%!astyle -A1pHcjUnwK -z2 -k1')
        else:
            vim.command("'<,'>!astyle -A1pHcjUnwK -z2 -k1")
        vim.command('set ff=%s' % ff) #恢复原来的行尾
        vim.command('normal `x')
    elif ft in ('xml',):
        vim.command('normal mx')
        vim.command(r'''silent! %s/>\(\s*$\)\@!/>\r/g''')
        vim.command(r'''silent! %s/\(^\s*\)\@<!</\r</g''')
        vim.command(r'''normal gg=G''')
        vim.command(r'''silent! %s/\s*$//g''') #删除行尾的空格
        vim.command(r'''silent! %m/asd^$(())fajl;''')
        vim.command('normal `x')
    else:
        print >> sys.stderr, "Format code: file type not supported!"

EOF_PYTHON
"==================================================================
"通用的配置
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
        "将iconv.dll复制到gvim.exe同目录下可解决UCS-BOM编码的文件显示乱码的问题
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

" 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）
if has('mouse')
    set mouse=a
endif

set guioptions-=T  "To  Remove toolbar   不显示工具栏
set guioptions+=c
set guioptions+=b

"右键弹出菜单
set mousemodel=popup

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" 在被分割的窗口间显示空白，便于阅读
set fillchars=vert:\ ,stl:\ ,stlnc:\

set sidescroll=20

" 增强模式中的命令行自动完成操作
set wildmenu
" 允许backspace和光标键跨越行边界
set whichwrap+=<,>,h,l

set statusline=%{expand('%:p:h')}%{g:isWin?'\\':'/'}%2*%t%1*%m%r%h%w%0*%=\ [%1*%{&ff=='unix'?'\\n':(&ff=='dos'?'\\r\\n':'\\r')},%{&fenc},%{&ft}%0*][%2*%02l,%02v,%04o,0x%04B%0*][%1*%{expand('%')!=''?strftime('%Y-%m-%d\ %H:%M:%S',getftime(expand('%:p'))):'-'}%0*][%2*%P%0*]
" 总是显示状态行
set laststatus=2
" 在编辑过程中，在右下角显示光标位置的状态行
set ruler

" 通过使用: commands命令，告诉我们文件的哪一行被改变过
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
set et  " 特殊情况需要关闭, makefile
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

"自动提示
let g:acp_enableAtStartup=1
let g:acp_mappingDriven=1
" let g:acp_behaviorSnipmateLength=1

" SuperTab completion fall-back 
let g:SuperTabDefaultCompletionType='<c-x><c-u><c-p>'
" SuperTab completion fall-back for context aware completion
" (incompatible with g:clang_auto_select=0, using the above)
" let g:SuperTabContextDefaultCompletionType='<c-x><c-u><c-p>'

