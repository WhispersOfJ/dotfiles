require "plugins"

local wk = require "which-key"

vim.opt.fileencodings = "ucs_bom,utf8,ucs-2le,ucs-2,iso-2022-jp-3,euc-jp,cp932"

vim.cmd [[packadd termdebug]]

vim.g.termdebug_useFloatingHover = 1
vim.g.termdebug_wide = 160

vim.api.nvim_create_augroup("vimrc", {})

-- Basic Setting {{{
vim.opt.bs = "indent,eol,start" -- allow backspacing over everything in insert mode
vim.opt.ai = true -- always set autoindenting on
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.shada = "'100,<1000,:10000,h"
vim.opt.history = 10000
vim.opt.ruler = true
vim.opt.nu = true
vim.opt.ambiwidth = "single"
vim.opt.display = "uhex"
vim.opt.scrolloff = 5 -- 常にカーソル位置から5行余裕を取る
vim.opt.virtualedit = "block"
vim.opt.autoread = true
vim.opt.background = "dark"
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 1000
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.conceallevel = 1
vim.opt.undofile = true
vim.opt.timeoutlen = 500
vim.opt.pumblend = 5 -- completions windows opacity

-- fileformat is local. fileformats is global.see more...(https://vim.fandom.com/wiki/File_format)
-- vim.opt.fileformats = "unix" -- use unix line endings for windows too.(if you want to change, you can use :set ff=dos)

-- gui configs
vim.cmd [[
if exists("g:neovide")
  set guifont=Monospace:h11
  let g:neovide_cursor_vfx_mode="wireframe"
  let g:neovide_transparency=0.6
  let g:neovide_cursor_vfx_mode = "railgun"
  function! FontSizePlus()
    let l:gf_size_whole = matchstr(&guifont, 'h\@<=\d\+$')
    let l:gf_size_whole = l:gf_size_whole + 1
    let l:new_font_size = l:gf_size_whole
    let &guifont = substitute(&guifont, 'h\d\+$', 'h' . l:new_font_size, '')
  endfunction
  function! FontSizeMinus()
    let l:gf_size_whole = matchstr(&guifont, 'h\@<=\d\+$')
    let l:gf_size_whole = l:gf_size_whole - 1
    let l:new_font_size = l:gf_size_whole
    let &guifont = substitute(&guifont, 'h\d\+$', 'h' . l:new_font_size, '')
  endfunction
  function! FontSizeReset()
    let &guifont = substitute(&guifont, 'h\d\+$', 'h11', '')
  endfunction
  nnoremap <C-=> :call FontSizePlus()<CR>
  nnoremap <C--> :call FontSizeMinus()<CR>
  nnoremap <C-0> :call FontSizeReset()<CR>
endif
]]

-- swap ; and :
vim.keymap.set("n", ";", ":", {})
vim.keymap.set("n", ":", ";", {})
vim.keymap.set("v", ";", ":", {})
vim.keymap.set("v", ":", ";", {})

-- Space prefix

-- Edit vimrc
local sfile = debug.getinfo(1, "S").short_src
vim.keymap.set("n", "<space>v", function()
    vim.cmd("edit " .. sfile)
end, { desc = "Edit init.lua" })

-- Reload vimrc"{{{
vim.api.nvim_create_user_command("ReloadVimrc", function()
    vim.fn.source(sfile)
    print "Reload vimrc"
end, { desc = "Reload init.lua" })
-- }}}

-- タブストップ設定
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.smarttab = true

-- 折り畳み設定
vim.opt.foldmethod = "marker"
vim.opt.foldcolumn = "auto:3"

-- 検索設定
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.cmd [[nohlsearch]] -- reset highlight
vim.keymap.set("n", "<space>/", ":noh<CR>", { silent = true })
vim.keymap.set("n", "*", "<Plug>(visualstar-*)N", { remap = true })
vim.keymap.set("n", "#", "<Plug>(visualstar-#)N", { remap = true })

-- ステータスライン表示
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.wildmenu = true
vim.opt.cmdheight = 2
vim.opt.wildmode = "list:full"
vim.opt.showcmd = true

-- tabline
vim.opt.showtabline = 2
vim.api.nvim_create_user_command("Te", "tabedit <args>", { nargs = "*", complete = "file" })
vim.api.nvim_create_user_command("Tn", "tabnew <args>", { nargs = "*", complete = "file" })
vim.keymap.set("n", "<S-Right>", ":<C-U>tabnext<CR>", { silent = true })
vim.keymap.set("n", "<S-Left>", ":<C-U>tabprevious<CR>", { silent = true })
-- vim.keymap.set("n", "L", ":<C-U>tabnext<CR>", { silent = true })
-- vim.keymap.set("n", "H", ":<C-U>tabprevious<CR>", { silent = true })
vim.keymap.set("n", "<C-L>", ":<C-U>tabmove +1<CR>", { silent = true })
vim.keymap.set("n", "<C-H>", ":<C-U>tabmove -1<CR>", { silent = true })

-- completion
vim.opt.complete = ".,w,b,u,t,i,d"
vim.keymap.set("i", "<C-X><C-O>", "<C-X><C-O><C-P>")

-- clipboard settings(vim's registers == clipboard)
if os.getenv("WSL_INTEROP") or os.getenv("WSL_DISTRO_NAME") then
    -- In case of WSL, specify the windows clipboard to prevent `display = ":0" error`.
    -- - https://github.com/asvetliakov/vscode-neovim/issues/103
    -- - https://github.com/Microsoft/WSL/issues/892
    if vim.fn.has("clipboard") or vim.fn.exists("g:vscode") then
        vim.api.nvim_create_augroup("WSLYank", {})
        vim.api.nvim_create_autocmd("TextYankPost", {
            group = "WSLYank",
            callback = function()
                vim.cmd [[ if v:event.operator ==# 'y' | call system('/mnt/c/Windows/System32/clip.exe', @0) | endif ]]
            end
        })
    end
else
    vim.opt.clipboard = "unnamedplus"
end

vim.keymap.set("n", "<space>;", "<cmd>Alpha<CR>", { silent = true, desc = "Show dashboard" })

-- バッファ切り替え
vim.opt.hidden = true

-- Tab表示
vim.opt.list = true
vim.opt.listchars = "tab:>-,trail:<"

-- タイトルを表示
vim.opt.title = true

-- 対応括弧を表示
vim.opt.showmatch = true

-- jkを直感的に
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "gj", "j", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })
vim.keymap.set("n", "gk", "k", { silent = true })
vim.keymap.set("n", "$", "g$", { silent = true })
vim.keymap.set("n", "g$", "$", { silent = true })
vim.keymap.set("v", "j", "gj", { silent = true })
vim.keymap.set("v", "gj", "j", { silent = true })
vim.keymap.set("v", "k", "gk", { silent = true })
vim.keymap.set("v", "gk", "k", { silent = true })
vim.keymap.set("v", "$", "g$", { silent = true })
vim.keymap.set("v", "g$", "$", { silent = true })

-- vscode like keymap
vim.keymap.set("n", "<space>q", ":q<CR>", { silent = true, desc = "Quit" }) -- <space+q> => quit editor
vim.keymap.set("n", "<space>w", ":w<CR>", { silent = true, desc = "Write file" }) -- <space+w> => write editor

vim.keymap.set("i", "jj", "<Esc>", { silent = true, desc = "to Normal mode" })
vim.keymap.set("i", "jk", "<Esc>", { silent = true, desc = "to Normal mode" })
vim.keymap.set("i", "kj", "<Esc>", { silent = true, desc = "to Normal mode" })

-- - Move current line to up/down `Alt+j/k`
-- Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { silent = true, desc = "move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { silent = true, desc = "move line up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .-2<CR>==", { silent = true, desc = "move line down" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==", { silent = true, desc = "move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "move line down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "move line up" })

-- JとDで半ページ移動
-- vim.keymap.set("n", "J", "<C-D>", { silent = true, desc = "move down" })
-- vim.keymap.set("n", "K", "<C-U>", { silent = true, desc = "move up" })

-- 編集中のファイルのディレクトリに移動
vim.cmd [[command! CdCurrent execute ":cd" . expand("%:p:h")]]
vim.keymap.set("n", ",c", ":<C-U>CdCurrent<CR>:pwd<CR>", { silent = true })

-- 最後に編集した場所にカーソルを移動する
vim.cmd [[autocmd! vimrc BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]]

-- colorscheme
-- 全角スペースをハイライト
vim.cmd [[autocmd! vimrc VimEnter,WinEnter * call matchadd('ZenkakuSpace', '　')]]

vim.cmd [[autocmd! vimrc ColorScheme * highlight ZenkakuSpace ctermbg=239 guibg=none]] -- toggleterm transparent

if vim.api.nvim_call_function('has', { 'nvim-0.8' }) ~= 1 then
    vim.cmd [[colorscheme duskfox]]
    -- vim.cmd [[colorscheme onedarkpro]]
else
    vim.cmd [[colorscheme onedarker]]
end


--Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
--If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
--(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.opt.termguicolors = true

-- neovim provider
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-----------------------------------------------------------}}}

-- filetype setter {{{
local file_type_setter_group = vim.api.nvim_create_augroup("FileTypeSetter", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "Steepfile" },
    group = file_type_setter_group,
    command = "set ft=ruby",
})
-- }}}

-- surround.vim {{{
vim.keymap.set("n", ",(", "csw(", { remap = true })
vim.keymap.set("n", ",)", "csw)", { remap = true })
vim.keymap.set("n", ",{", "csw{", { remap = true })
vim.keymap.set("n", ",}", "csw}", { remap = true })
vim.keymap.set("n", ",[", "csw[", { remap = true })
vim.keymap.set("n", ",]", "csw]", { remap = true })
vim.keymap.set("n", ",'", "csw'", { remap = true })
vim.keymap.set("n", ',"', 'csw"', { remap = true })
--}}}

-- from http://vim-users.jp/2011/04/hack214/ {{{
vim.keymap.set("v", "(", "t(", { remap = true })
vim.keymap.set("v", ")", "t)", { remap = true })
vim.keymap.set("v", "]", "t]", { remap = true })
vim.keymap.set("v", "[", "t[", { remap = true })
vim.keymap.set("o", "(", "t(", { remap = true })
vim.keymap.set("o", ")", "t)", { remap = true })
vim.keymap.set("o", "]", "t]", { remap = true })
vim.keymap.set("o", "[", "t[", { remap = true })
-- }}}

-- set paste
vim.cmd [[nnoremap <silent> ,p :<C-U>set paste!<CR>:<C-U>echo("Toggle PasteMode => " . (&paste == 0 ? "Off" : "On"))<CR>]]

-- eskk {{{
vim.g["eskk#large_dictionary"] = { path = "/usr/share/skk/SKK-JISYO.L", sorted = 1, encoding = "euc-jp" }
-- }}}

-- UTF8、SJIS(CP932)、EUCJPで開き直す {{{
vim.cmd [[command! -bang -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>]]
vim.cmd [[command! -bang -nargs=? Sjis edit<bang> ++enc=cp932 <args>]]
vim.cmd [[command! -bang -nargs=? Euc edit<bang> ++enc=eucjp <args>]]
-- }}}

-- YAMLファイル用タブストップ設定
vim.cmd [[au FileType yaml setlocal expandtab ts=2 sw=2 fenc=utf-8]]

-- For avsc
vim.cmd [[autocmd! vimrc BufNewFile,BufRead *.avsc set filetype=json]]

-- smartchr {{{
vim.cmd [[
function! s:EnableSmartchrBasic()
  inoremap <buffer><expr> + smartchr#one_of(' + ', '+', '++')
  inoremap <buffer><expr> & smartchr#one_of(' & ', ' && ', '&')
  inoremap <buffer><expr> , smartchr#one_of(', ', ',')
  inoremap <buffer><expr> <Bar> smartchr#one_of('<Bar>', ' <Bar><Bar> ', '<Bar><Bar>')
  inoremap <buffer><expr> = search('\(&\<bar><bar>\<bar>+\<bar>-\<bar>/\<bar>>\<bar><\) \%#', 'bcn')? '<bs>= ' : search('\(\*\<bar>!\)\%#')? '= ' : smartchr#one_of(' = ', ' == ', '=')
endfunction

function! s:EnableSmartchrRegExp()
  inoremap <buffer><expr> ~ search('\(!\<bar>=\) \%#', 'bcn')? '<bs>~ ' : '~'
endfunction

function! s:EnableSmartchrRubyHash()
  inoremap <buffer><expr> > smartchr#one_of('>', '>>', ' => ')
endfunction

autocmd vimrc FileType c,cpp,php,python,javascript,ruby,vim call s:EnableSmartchrBasic()
autocmd vimrc FileType python,ruby,vim call s:EnableSmartchrRegExp()
autocmd vimrc FileType ruby call s:EnableSmartchrRubyHash()
autocmd vimrc FileType ruby,eruby setlocal tags+=gems.tags,./gems.tags,~/rtags
autocmd vimrc FileType haml call s:EnableSmartchrHaml()
]]
-- }}}

-- shファイルの保存時にはファイルのパーミッションを755にする {{{
vim.cmd [[
function! s:ChangeShellScriptPermission()
  if !has("win32")
    if &ft =~ "\\(z\\|c\\|ba\\)\\?sh$" && expand('%:t') !~ "\\(zshrc\\|zshenv\\)$"
      call system("chmod 755 " . shellescape(expand('%:p')))
      echo "Set permission 755"
    endif
  endif
endfunction
autocmd vimrc BufWritePost * call s:ChangeShellScriptPermission()
]]
-- }}}

-- TOhtml
vim.g.html_number_lines = 0
vim.g.html_use_css = 1
vim.g.use_xhtml = 1
vim.g.html_use_encoding = "utf-8"

-- quickrun{{{
vim.cmd [[
autocmd vimrc FileType quickrun setlocal concealcursor=""

vnoremap <leader>q :QuickRun >>buffer -mode v<CR>
let g:quickrun_config = {}
let g:quickrun_config._ = {
      \'runner' : 'vimproc',
      \'outputter/buffer/split' : ':botright 10sp',
      \'outputter/error': 'buffer',
      \'runner/vimproc/updatetime' : 40,
      \'hook/now_running/enable' : 1,
      \'hook/time/enable' : 1,
      \}

let g:quickrun_config.ruby = {
  \ 'cmdopt': '-W2',
  \ 'exec': 'bundle exec %c %o %s %a',
  \ }
]]
-- }}}

-- vim-test
wk.register({
    ["<space>t"] = {
        name = "+Test",
    },
})
vim.keymap.set("n", "<space>tn", ":TestNearest<cr>")
vim.keymap.set("n", "<space>tf", ":TestFile<cr>")

vim.cmd [[let test#strategy = 'toggleterm']]

vim.cmd [[let test#ruby#rspec#executable = 'rspec']]

vim.cmd [[
function! DockerTransformer(cmd) abort
  if $APP_CONTAINER_NAME != ''
    let container_id = trim(system('docker ps --filter name=$APP_CONTAINER_NAME -q'))
    return 'docker exec -t ' . container_id . ' bundle exec ' . a:cmd
  else
    return 'bundle exec ' . a:cmd
  endif
endfunction

let g:test#custom_transformations = {'docker': function('DockerTransformer')}
let g:test#transformation = 'docker'
]]

-- webapi-vim
vim.g["webapi#system_function"] = "vimproc#system"

-- vista.vim {{{
vim.g.vista_default_executive = "ctags"
vim.g.vista_icon_indent = { "╰─▸ ", "├─▸ " }
vim.g.vista_executive_for = { rust = "lcn" }
vim.keymap.set("n", "<leader>v", ":<C-U>Vista!!<CR>", { silent = true })
-- }}}

-- Fugitive {{{
wk.register({
    [",g"] = {
        name = "+git",
    },
})
vim.keymap.set("n", ",gd", ":<C-u>DiffviewOpen<CR>")
vim.keymap.set("n", ",gs", ":<C-u>Git<CR>")
vim.keymap.set("n", ",gl", ":<C-u>Gclog HEAD~20..HEAD<CR>")
vim.keymap.set("n", ",gh", ":<C-u>DiffviewFileHistory %<CR>")
vim.keymap.set("n", ",ga", ":<C-u>Gwrite<CR>")
vim.keymap.set("n", ",gc", ":<C-u>Git commit<CR>")
vim.keymap.set("n", ",gC", ":<C-u>Git commit --amend<CR>")
vim.keymap.set("n", ",gb", ":<C-u>Git blame<CR>")
vim.keymap.set("n", ",gn", ":<C-u>Git now<CR>")
vim.keymap.set("n", ",gN", ":<C-u>Git now --all<CR>")
vim.keymap.set("n", ",gp", ":<C-u>GHPRBlame<CR>")

vim.cmd [[autocmd vimrc BufEnter * if expand("%") =~ ".git/COMMIT_EDITMSG" | set ft=gitcommit | endif]]
vim.cmd [[autocmd vimrc BufEnter * if expand("%") =~ ".git/rebase-merge" | set ft=gitrebase | endif]]
vim.cmd [[autocmd vimrc BufEnter * if expand("%:t") =~ "PULLREQ_EDITMSG" | set ft=gitcommit | endif]]
-- }}}

-- vim-choosewin {{{
vim.keymap.set("n", "_", "<Plug>(choosewin)", { remap = true })
-- }}}

-- switch.vim {{{
vim.cmd [[
let g:variable_style_switch_definitions = [
      \   {
      \     '\<[a-z0-9]\+_\k\+\>': {
      \       '_\(.\)': '\U\1'
      \     },
      \     '\<[a-z0-9]\+[A-Z]\k\+\>': {
      \       '\([A-Z]\)': '_\l\1'
      \     },
      \   }
      \ ]
nnoremap <silent><C-c> :Switch<CR>
nnoremap <silent>- :Switch<CR>
nnoremap + :call switch#Switch(g:variable_style_switch_definitions)<cr>

let g:switch_custom_definitions = [
      \ ['and', 'or'],
      \ ['it', 'specify'],
      \ ['describe', 'context'],
      \ ['yes', 'no'],
      \ ['on', 'off'],
      \ ['public', 'protected', 'private'],
\ ]
]]
-- }}}

-- github-complete.vim' {{{
vim.cmd [[
  " Disable overwriting 'omnifunc'
  let g:github_complete_enable_omni_completion = 0
  augroup ConfigGithubComplete
    " <C-x><C-x> invokes completions of github-complete.vim
    autocmd! FileType markdown,gitcommit
          \ imap <C-x><C-x> <Plug>(github-complete-manual-completion)
  augroup END
]]
-- }}}

-- vim-markdown
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_conceal_code_blocks = 0
vim.g.vim_markdown_new_list_item_indent = 0

-- Quickfix
vim.keymap.set("n", ",q", ":<C-U>copen<CR>", { silent = true })
vim.keymap.set("n", "]q", ":<C-U>cnext<CR>", { silent = true })
vim.keymap.set("n", "[q", ":<C-U>cprev<CR>", { silent = true })
vim.keymap.set("n", "]Q", ":<C-U>clast<CR>", { silent = true })
vim.keymap.set("n", "[Q", ":<C-U>cfirst<CR>", { silent = true })

-- errormarker.vim
vim.cmd [[let errormarker_disablemappings = 1]]

-- Merge Setting
vim.cmd [[
if &diff
  nmap <buffer> <leader>1 :diffget LOCAL<CR>
  nmap <buffer> <leader>2 :diffget BASE<CR>
  nmap <buffer> <leader>3 :diffget REMOTE<CR>
endif
]]

-- Tabular {{{
wk.register({
    ["<leader>a"] = { name = "+Tabularize" },
})
vim.keymap.set("n", "<Leader>a,", ":Tabularize /,<CR>")
vim.keymap.set("n", "<Leader>a=", ":Tabularize /=<CR>")
vim.keymap.set("n", "<Leader>a>", ":Tabularize /=><CR>")
vim.keymap.set("n", "<Leader>a:", ":Tabularize /:\zs<CR>")
vim.keymap.set("n", "<Leader>a<Bar>", ":Tabularize /<Bar><CR>")

vim.keymap.set("v", "<Leader>a,", ":Tabularize /,<CR>")
vim.keymap.set("v", "<Leader>a=", ":Tabularize /=<CR>")
vim.keymap.set("v", "<Leader>a>", ":Tabularize /=><CR>")
vim.keymap.set("v", "<Leader>a:", ":Tabularize /:\zs<CR>")
vim.keymap.set("v", "<Leader>a<Bar>", ":Tabularize /<Bar><CR>")
-- }}}

-- qfreplace
vim.cmd [[autocmd vimrc FileType qf nnoremap <buffer> r :<C-U>Qfreplace<CR>]]

-- ale {{{
vim.g.ale_linters = { ruby = { "ruby" } }
vim.g.ale_linters_explicit = 1
vim.g.ale_cache_executable_check_failures = 1
vim.g.ale_lua_luacheck_options = "--globals vim"
-- }}}

-- ag.vim
vim.g.ag_prg = "rg --vimgrep --smart-case"

-- toggleterm {{{
vim.keymap.set("t", "<A-n>", "<C-\\><C-n>")
vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<A-l>", "<C-\\><C-N><C-w>l")

vim.keymap.set("n", "<F9>", "<cmd>ToggleTermSendCurrentLine<cr>")
vim.keymap.set("v", "<F9>", "<cmd>ToggleTermSendVisualSelection<cr>")
--- }}}

-- nvim-editcommand
vim.g.editcommand_prompt = "%"

-- Git commands
vim.cmd [[command! -nargs=+ Tg :T git <args>]]
-- }}}

-- markdown-composer
vim.g.markdown_composer_autostart = 0
vim.g.markdown_composer_refresh_rate = 10000

-- ghost_text
vim.cmd [[
augroup nvim_ghost_user_autocommands
  au User *github.com set filetype=markdown
augroup END
]]

-- vim-terraform
vim.g.terraform_fmt_on_save = 1

-- rust.vim
vim.g.rustfmt_autosave = 1

vim.cmd [[autocmd vimrc FileType rust let termdebugger = "rust-gdb"]]

vim.g.cursorhold_updatetime = 100

-- LSP configs {{{

vim.keymap.set("n", "<space>le", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "diagnostic open" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "diagnostic go prev" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "diagnostic go next" })
vim.keymap.set("n", "<space>ll", vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "diagnostic list" })

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.jsonc.filetype_to_parsename = "json"
-- parser_config.jsonc.used_by = "json"


-- local auto_install_servers = {
--     "pylsp",
--     "lua_ls",
-- }

local lsp_zero = require('lsp-zero')
lsp_zero.preset('recommended')
-- lsp_zero.ensure_installed(auto_install_servers)
lsp_zero.setup()

local servers = {
    'dockerls',
    'powershell_es',
    'pylsp',
    'remark_ls',
    'rust_analyzer',
    'tsserver',
    'vimls',
    'yamlls',
}

local lsp_common = require "lsp_common"
local on_attach = lsp_common.on_attach
local capabilities = lsp_common.capabilities
local add_bundle_exec = lsp_common.add_bundle_exec
local lspconfig = require "lspconfig"

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        }
    }
end

-- suppress clangd encoding warning
-- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
capabilities.offsetEncoding = { "utf-16" }
lspconfig["clangd"].setup({
    on_attach = on_attach,
    capabilities = capabilities,
})

-- rust-analyzer
require("rust-tools").setup({
    tools = {
        autoSetHints = true,
        inlay_hints = {
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },
    server = {
        on_attach = on_attach,
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
})

lspconfig["lua_ls"].setup {
    on_attach = on_attach,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
}

-- use json schema
lspconfig["jsonls"].setup({
    on_attach = on_attach,
    settings = {
        json = {
            schemas = vim.list_extend(
                {
                    {
                        description = 'VSCode devcontaier',
                        fileMatch = { 'devcontainer.json' },
                        name = 'devcontaier.json',
                        url = 'https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.schema.json',
                    },
                },
                require('schemastore').json.schemas {
                }
            ),
        },
    },
    setup = {
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
                end,
            },
        },
    },
})

lspconfig.steep.setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        vim.keymap.set("n", "<space>lt", function()
            client.request("$/typecheck", { guid = "typecheck-" .. os.time() }, function()
            end, bufnr)
        end, { silent = true, buffer = bufnr, desc = "lsp typecheck" })
    end,
    on_new_config = function(config, root_dir)
        add_bundle_exec(config, "steep", root_dir)
        return config
    end,
})

local lspconfig_configs = require "lspconfig.configs"
local lspconfig_util = require "lspconfig.util"

lspconfig_configs["teal_ls"].setup({
    on_attach = on_attach,
    -- root_dir = lspconfig_util.root_pattern("main.tl")
})

if not lspconfig_configs["ruby-lsp"] then
    lspconfig_configs["ruby-lsp"] = {
        default_config = {
            cmd = { "bundle", "exec", "ruby-lsp" },
            filetypes = { "ruby" },
            root_dir = lspconfig_util.root_pattern("Gemfile", ".git"),
            init_options = {
                enabledFeatures = {
                    "documentHighlights",
                    "documentSymbols",
                    "foldingRanges",
                    "selectionRanges",
                    "semanticHighlighting",
                    "formatting",
                    "diagnostics",
                    "codeActions",
                },
            },
        },
        docs = {
            description = [[https://github.com/Shopify/ruby-lsp]],
            default_config = {
                root_dir = [[root_pattern(".git")]],
            },
        },
    }
end

local methods = require("null-ls.methods")
local helpers = require("null-ls.helpers")

local function ruff_fix()
    return helpers.make_builtin({
        name = "ruff",
        meta = {
            url = "https://github.com/charliermarsh/ruff/",
            description = "An extremely fast Python linter, written in Rust.",
        },
        method = methods.internal.FORMATTING,
        filetypes = { "python" },
        generator_opts = {
            command = "ruff",
            args = { "--fix", "-e", "-n", "--stdin-filename", "$FILENAME", "-" },
            to_stdin = true
        },
        factory = helpers.formatter_factory
    })
end

local null_ls = require("null-ls")

null_ls.setup({
    capabilities = capabilities,
    sources = {
        null_ls.builtins.formatting.stylua.with({
            condition = function(utils)
                return utils.root_has_file({ ".stylua.toml" })
            end,
        }),
        null_ls.builtins.formatting.rubocop.with({
            prefer_local = "bundle_bin",
            condition = function(utils)
                return utils.root_has_file({ ".rubocop.yml" })
            end,
        }),
        null_ls.builtins.diagnostics.rubocop.with({
            prefer_local = "bundle_bin",
            condition = function(utils)
                return utils.root_has_file({ ".rubocop.yml" })
            end,
        }),
        null_ls.builtins.diagnostics.luacheck.with({
            extra_args = { "--globals", "vim", "--globals", "awesome" },
        }),
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.completion.spell,
        null_ls.builtins.diagnostics.codespell.with({
            condition = function()
                return vim.fn.executable("codespell") > 0
            end
        }),
        ruff_fix(),
        null_ls.builtins.diagnostics.ruff.with({
            condition = function()
                return vim.fn.executable("ruff") > 0
            end
        }),
    },
})
-- }}}
-- }}}

-- Packer {{{
wk.register({
    ["<space>p"] = {
        name = "+Packer",
    },
})
vim.keymap.set("n", "<space>pS", "<cmd>PackerStatus<CR>", { silent = true, desc = "Show plugins status" })
vim.keymap.set("n", "<space>pc", "<cmd>PackerCompile<CR>", { silent = true, desc = "Compile plugins" })
vim.keymap.set("n", "<space>pi", "<cmd>PackerInstall<CR>", { silent = true, desc = "Install plugins" })
vim.keymap.set("n", "<space>pr", "<cmd>PackerReload<CR>", { silent = true, desc = "Reload plugins" })
vim.keymap.set("n", "<space>ps", "<cmd>PackerSync<CR>", { silent = true, desc = "Sync plugins" })
-- }}}
