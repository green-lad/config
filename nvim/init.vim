" TODO
" - folding behaves by inproduceable closing folds when pasting / editing

" plugins
    " vim-plug setup
        let s:vimrcFolder=fnamemodify($MYVIMRC, ":p:h")
        let s:pluginFolder=s:vimrcFolder . "/plugs"

        let s:customPluginName="vim-custom-misc"
        let s:customPlugin = s:pluginFolder . "/" . s:customPluginName

        let s:pluginManagerFolder=s:vimrcFolder . "/autoload"
        let &rtp .= ','.expand(s:pluginManagerFolder)

    let s:plugins = [
        \   {
        \       "name": "neosnippet",
        \       "root": "https://github.com/Shougo"
        \   },
        \   {
        \       "name": "vim-commentary",
        \       "root": "https://github.com/tpope"
        \   },
        \   {
        \       "name": "vim-fugitive",
        \       "root": "https://github.com/tpope"
        \   },
        \   {
        \       "name": "neomake",
        \       "root": "https://github.com/neomake"
        \   },
        \   {
        \       "name": "wilder.nvim",
        \       "root": "https://github.com/gelguy",
        \       "func": "UpdateRemotePlugins"
        \   },
        \   {
        \       "name": s:customPluginName,
        \       "root": s:pluginFolder
        \   },
        \]
    let s:onlyUseLocal = 0

    function! UpdateRemotePlugins(...)
        " Needed to refresh runtime files
        let &rtp=&rtp
        UpdateRemotePlugins
    endfunction

    function! UseVimPlug(pluginFolder, pluginManagerFolder, plugins, onlyUseLocal)
        let l:url = 
            \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        let l:path = a:pluginManagerFolder . "/plug.vim"
        if empty(glob(l:path))
            exe "!curl -fLo " . l:path . " --create-dirs " . l:url
        endif
        if !empty(glob(a:pluginFolder))
            let &runtimepath .= ','.expand(a:pluginFolder)
            call plug#begin(a:pluginFolder)
                for plugin in a:plugins
                    if a:onlyUseLocal
                        if has_key(plugin, 'func')
                            exec "Plug '" . a:pluginFolder . "/" . plugin['name'] . "', {'do': function('" . plugin['func'] . "') }"
                        else
                            exec "Plug '" . a:pluginFolder . "/" . plugin['name'] . "'"
                        endif
                    else
                        if has_key(plugin, 'func')
                            exec "Plug '" . plugin['root'] . "/" . plugin['name'] . "', {'do': function('" . plugin['func'] . "') }"
                        else
                            exec "Plug '" . plugin['root'] . "/" . plugin['name'] . "'"
                        endif
                    endif
                endfor
            call plug#end()
        endif
    endfunction

    call UseVimPlug(s:pluginFolder, s:pluginManagerFolder, s:plugins, s:onlyUseLocal)

    " neosnippet
        imap <C-k> <Plug>(neosnippet_expand_or_jump)
        smap <C-k> <Plug>(neosnippet_expand_or_jump)
        xmap <C-k> <Plug>(neosnippet_expand_target)
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
        let g:neosnippet#snippets_directory =
            \ fnamemodify($MYVIMRC, ":p:h") . "/snippets"
        let g:neosnippet#disable_runtime_snippets = {'_':1}
        nnoremap <leader>s :NeoSnippetEdit -split<Cr>
    " fzf
        function! s:openFzfResultOfGrepInput(word)
            let s:actionMap = {
            \     '': 'edit',
            \     'ctrl-v': 'vsplit',
            \     'ctrl-s': 'split',
            \     'ctrl-t': 'tab split'
            \ }
            let s:file = substitute(a:word[1], '\:.*', "", "")
            let s:lineNumber = substitute(a:word[1], '.\{-}\:', "", "")
            let s:lineNumber = substitute(s:lineNumber, '\:.*', "", "")
            let s:key = a:word[0]

            exec s:actionMap[s:key] . " +" . s:lineNumber . " " . s:file
        endfunction

        command! -bang -complete=dir -nargs=? ED 
            \ call fzf#run(
            \    {
            \        'source': 'grep --line-buffered --color=never -n -r "" *',
            \        'sink*': function('s:openFzfResultOfGrepInput'),
            \        'options': "--expect=ctrl-v,ctrl-s,ctrl-t",
            \        'window': {'width': 0.9, 'height': 0.6}
            \     }, <bang>0
            \ )

        nnoremap <leader>f :ED<CR>
    " wilder
        call wilder#setup({
            \ 'modes': [':', '/', '?'],
            \ 'next_key': '<Tab>',
            \ 'previous_key': '<S-Tab>',
            \ 'accept_key': '/',
            \ 'reject_key': '.',
            \ })

" indent
    set shiftwidth=0
    set shiftround
    set expandtab
    set tabstop=2

" folding
    function! FoldByIndent(lnum)
        function! IndentLevel(lnum)
            let l:spacesPerIndent = &shiftwidth
            if l:spacesPerIndent == 0
                let l:spacesPerIndent = &tabstop
            endif
            return indent(a:lnum) / l:spacesPerIndent
        endfunction

        function! IsEmptyLine(lnum)
            return getline(a:lnum) =~? '\v^\s*$'
        endfunction

        let l:lastlevel = foldlevel(a:lnum - 1)
        if IsEmptyLine(a:lnum)
            if lastlevel > IndentLevel(a:lnum + 1) && !IsEmptyLine(a:lnum)
                return l:lastlevel - 1
            else
                return '-1'
            endif
        endif
        let l:cur = IndentLevel(a:lnum)
        let l:next = IndentLevel(a:lnum+1)
        let l:prev = IndentLevel(a:lnum-1)
        if l:cur < &foldnestmax
            if l:cur < l:next
                return '>' . (l:cur + 1)
            elseif l:cur < l:prev
                return l:cur + 1
            else
                return l:cur
            endif
        endif
        return &foldnestmax
    endfunction

    set foldnestmax=5
    set foldexpr=FoldByIndent(v:lnum)
    set foldmethod=expr
    set nofoldenable

" completion
    set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind
    set suffixes+=.idx,.ilg,.inx,.out,.toc,.png,.jpg
    set wildmenu
    set wildmode=full
    set wildoptions-=pum

" searching
    set fileignorecase
    set smartcase
    set ignorecase
    set incsearch

" cmdwin
    set cmdwinheight=5
    " execute printf('nnoremap : :%s', &cedit)
    " execute printf('nnoremap / /%s', &cedit)
    " execute printf('nnoremap ? ?%s', &cedit)
    au CmdwinEnter * startinsert
    au CmdwinEnter * nnoremap <buffer> <ESC> <C-\><C-N>
    au CmdwinEnter * nnoremap <buffer> <C-c> <C-\><C-N>
    au CmdwinEnter * inoremap <buffer> <C-c> <Esc>
    au CmdwinEnter * nnoremap <buffer> : _
    au CmdwinEnter * inoremap <buffer> <C-CR> <CR>
    au CmdwinEnter * inoremap <buffer> <expr> <backspace>
        \ col(".") == 1 ? '<C-\><C-N><C-\><C-N>' : '<backspace>'

" maps
    let mapleader = ","
    noremap <leader>. :s::g<Left><Left>
    noremap <leader>w :%s:\(<c-r>=expand("<cword>")<cr>\)::g<Left><Left>
    noremap <leader>% :%s::g<Left><Left>
    noremap <leader>i :e $MYVIMRC<Cr>
    noremap <leader>r :source $MYVIMRC<Cr>
    noremap <leader>h :set hlsearch!<Cr>

    noremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR><CR>
    noremap <leader>t :tabe <C-R>=expand("%:p:h") . "/" <CR><CR>
    noremap <leader>s :split <C-R>=expand("%:p:h") . "/" <CR><CR>

    function! PasteFromExtern()
        let l:pasteSetting = &paste
        set paste
        normal! "+p
        let &paste = l:pasteSetting
    endfunction
    noremap <leader>p :call PasteFromExtern()<Cr>
    execute printf('nnoremap <silent> <leader>c :execute printf(''e %s/ftplugin/%%s.vim'', &ft)<Cr>', s:customPlugin)
    cmap <leader>( \(\)<Left><Left>
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
    nnoremap <leader>b :exec "sp " . s:customPlugin . "/ftplugin/" . &filetype . ".vim"<cr>

" look
    syntax on
    set conceallevel=0
    au FileType * setl cole=0
    colorscheme nocolor
    set listchars=tab:├─,eol:$,space:~,conceal:*
    set relativenumber
    set number
    set confirm
    set splitbelow
    set splitright
    set nohlsearch

    " colors
        syntax on
        set colorcolumn=100
        colorscheme nocolor
        " TODO: implement following function
        function! s:getPathToColorschemesByName()
        endfunction
        " TODO: use getPathToColorschemesByName to not have shortcut hardcoded
        " for colorscheme
        execute printf('nnoremap <leader>c :sp %s/colors/nocolor.vim<Cr>', s:customPlugin)

" winows spefic setting
    if has('win32')
        set shell=powershell.exe
        set shellcmdflag=-NoProfile\ -NoLogo\ -NonInteractive\ -Command
        set shellpipe=|
        set shellredir=>
        set shellxquote=
        set shellquote=
        autocmd FileChangedRO * silent exec '!tf checkout ' expand('%')

        nnoremap <C-z> <nop>
        inoremap <C-z> <nop>
        vnoremap <C-z> <nop>
        snoremap <C-z> <nop>
        xnoremap <C-z> <nop>
        cnoremap <C-z> <nop>
        onoremap <C-z> <nop>
    endif

" ideas
    " - move to last character like in this plugin: https://www.vim.org/scripts/script.php?script_id=3386 (eg via d-f/ or d-2f/)
