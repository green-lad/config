{ config, pkgs, inputs, ... }: {
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = ",";
    };

    colorscheme = "monotone";

    opts = {
      number = true;
      colorcolumn = "100";
      relativenumber = true;
      shiftwidth = 0;
      tabstop = 2;
      expandtab = true;
      shiftround = true;
      wrap = true;
      swapfile = false;
      backup = false;
      hlsearch = false;
      incsearch = true;
      fileignorecase = true;
      smartcase = true;
      ignorecase = true;
      scrolloff = 0;
      signcolumn = "yes";
      foldlevelstart = 99;
      cmdwinheight = 5;
      conceallevel = 0;
      listchars = "tab:├─,eol:$,space:~,conceal:*";
      confirm = true;
      splitbelow = true;
      splitright = true;
      rulerformat = "%l,%c,0x%B";
      modelineexpr = true;
      foldnestmax = 5;
      foldexpr = "FoldByIndent(v:lnum)";
      foldmethod = "expr";
      suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg";
      wildmenu = true;
      wildmode = "full";
      wildoptions = "tagfile";
      foldenable = true;
      clipboard = "unnamedplus";
    };

    # TODO: explicitly add plugins for when neovim gets started with a wrapped package (see polybar) by not hardcoding them
    extraConfigLuaPre = ''
      vim.opt.runtimepath:prepend("/nix/store/jr2z31afi2bj8y36wylff36p0g01n7jz-vim-pack-dir")
      vim.opt.runtimepath:prepend("/nix/store/jr2z31afi2bj8y36wylff36p0g01n7jz-vim-pack-dir/pack/*/start/*")
    '';

    extraConfigLua = ''
      require("kitty-scrollback").setup()
    '';

    extraPlugins = with pkgs.vimPlugins; [
      kitty-scrollback-nvim
      fileline-nvim # open files at line and char (example: nvim foo.lua:12:5)
    ]
    ++ [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "vim-monotone";
        version = "0.0.1";
        src = pkgs.fetchFromGitHub {
          owner = "Lokaltog";
          repo = "vim-monotone";
          rev = "5393343ff2d639519e4bcebdb54572dfe5c35686";
          hash = "sha256-BMN+3pgF7NgMkEpmMNTjZmSjWiVliBkwzQ9vw+Mq33M=";
        };
      })
    ];

    extraPackages = with pkgs; [
      nerd-fonts.sauce-code-pro
    ];

    extraConfigVim = ''
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

function! PasteFromExtern()
    let l:pasteSetting = &paste
    set paste
    normal! "+p
    let &paste = l:pasteSetting
endfunction
noremap <leader>p :call PasteFromExtern()<Cr>

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

execute printf('nnoremap : :%s', &cedit)
execute printf('nnoremap / /%s', &cedit)
execute printf('nnoremap ? ?%s', &cedit)
au CmdwinEnter * startinsert
au CmdwinEnter * nnoremap <buffer> <ESC> <C-\><C-N>
au CmdwinEnter * nnoremap <buffer> <C-c> <C-\><C-N>
au CmdwinEnter * inoremap <buffer> <C-c> <Esc>
au CmdwinEnter * nnoremap <buffer> : _
au CmdwinEnter * inoremap <buffer> <C-CR> <CR>
au CmdwinEnter * inoremap <buffer> <expr> <backspace>
    \ col(".") == 1 ? '<C-\><C-N><C-\><C-N>' : '<backspace>'
    '';
  };
}
