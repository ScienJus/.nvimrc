" automatic installation vim-plug
" - https://github.com/junegunn/vim-plug/wiki/tips
" - https://github.com/junegunn/vim-plug/issues/739

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }

" try clang
Plug 'Shougo/deoplete-clangx'

call plug#end()

" build cquery: https://github.com/cquery-project/cquery/wiki/Building-cquery
" configure cquery: https://github.com/cquery-project/cquery/wiki/Neovim
let g:LanguageClient_serverCommands = {
    \ 'cpp': ['cquery', '--log-file=/tmp/cq.log'],
    \ 'c': ['cquery', '--log-file=/tmp/cq.log'],
    \ }

let g:LanguageClient_rootMarkers = {
    \ 'cpp': ['.git', 'compile_commands.json', 'build'],
    \ 'c': ['.git', 'compile_commands.json', 'build'],
    \ }

let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
let g:LanguageClient_hoverPreview = 'Never'

let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1

" configure deoplete: https://www.jianshu.com/p/3f78c12ce447
call deoplete#custom#source('LanguageClient',
    \ 'min_pattern_length',
    \ 2)

call deoplete#custom#source('_',
    \ 'disabled_syntaxes', ['String']
    \ )

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

call deoplete#custom#option('sources', {
   \ 'cpp':['LanguageClient', 'clangx'],
   \ 'c': ['LanguageClient', 'clangx'],
   \ 'vim': ['vim'],
   \ 'zsh': ['zsh']
   \})

let g:deoplete#ignore_sources = {}
let g:deoplete#ignore_sources._ = ['buffer', 'around']

" configure defx: https://learnku.com/articles/34885
call defx#custom#option('_', {
    \ 'winwidth': 30,
    \ 'split': 'vertical',
    \ 'direction': 'topleft',
    \ 'show_ignored_files': 0,
    \ 'buffer_name': '',
    \ 'toggle': 1,
    \ 'resume': 1
    \ })

let mapleader=","

" language client
nnoremap <silent> gh   :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd   :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gr   :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> gs   :call LanguageClient#textDocument_documentSymbol()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" defx
nmap <silent> <Leader>e :Defx <cr>

autocmd FileType defx call s:defx_mappings()

function! s:defx_mappings() abort
    nnoremap <silent><buffer><expr> l     <SID>defx_toggle_tree()
    nnoremap <silent><buffer><expr> .     defx#do_action('toggle_ignored_files')
    nnoremap <silent><buffer><expr> <C-r> defx#do_action('redraw')
endfunction

function! s:defx_toggle_tree() abort
    " Open current file, or toggle directory expand/collapse
    if defx#is_directory()
        return defx#do_action('open_or_close_tree')
    endif
    return defx#do_action('multi', ['drop'])
endfunction

" clang binary path
call deoplete#custom#var('clangx', 'clang_binary', '/usr/bin/clang')

" clangx options
call deoplete#custom#var('clangx', 'default_c_options', '')
call deoplete#custom#var('clangx', 'default_cpp_options', '')

autocmd FileType cpp setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType c setlocal expandtab shiftwidth=2 softtabstop=2
