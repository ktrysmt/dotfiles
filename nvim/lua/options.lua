vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu   = 1
vim.g.did_indent_on             = 1
-- vim.g.did_load_filetypes        = 1
vim.g.did_load_ftplugin         = 1
vim.g.loaded_2html_plugin       = 1
vim.g.loaded_gzip               = 1
vim.g.loaded_man                = 1
vim.g.loaded_matchit            = 1
vim.g.loaded_matchparen         = 1
vim.g.loaded_netrwPlugin        = 1
vim.g.loaded_remote_plugins     = 1
vim.g.loaded_shada_plugin       = 1
vim.g.loaded_spellfile_plugin   = 1
vim.g.loaded_tarPlugin          = 1
vim.g.loaded_tutor_mode_plugin  = 1
vim.g.loaded_zipPlugin          = 1
vim.g.skip_loading_mswin        = 1
vim.g.editorconfig              = false
vim.g.omni_sql_no_default_maps  = 1

vim.g.mapleader                 = " "
vim.g.maplocalleader            = " "

vim.opt.encoding                = 'utf-8'
vim.opt.fileencodings           = 'utf-8'
vim.opt.fileformats             = 'unix,dos,mac'

vim.opt.backspace               = 'start,eol,indent'
vim.opt.clipboard               = 'unnamed'
vim.opt.cursorline              = true
vim.opt.diffopt                 = 'internal,filler,algorithm:histogram,indent-heuristic'
vim.opt.display                 = 'lastline'
vim.opt.expandtab               = true
vim.opt.hidden                  = true
vim.opt.history                 = 4096
vim.opt.hlsearch                = true
vim.opt.inccommand              = 'split'
vim.opt.incsearch               = true
vim.opt.laststatus              = 2
vim.opt.lazyredraw              = true
vim.opt.list                    = true
vim.opt.matchtime               = 1
vim.opt.number                  = true
vim.opt.ruler                   = true
vim.opt.secure                  = true
vim.opt.sh                      = 'zsh'
vim.opt.shiftwidth              = 2
vim.opt.shortmess               = 'I'
vim.opt.showcmd                 = true
vim.opt.showmatch               = true
vim.opt.showmode                = false
vim.opt.showtabline             = 1
vim.opt.signcolumn              = 'yes'
vim.opt.smartindent             = true
vim.opt.softtabstop             = 2
vim.opt.splitbelow              = true
-- vim.opt.splitright              = true
vim.opt.swapfile                = false
vim.opt.tabstop                 = 2
vim.opt.termguicolors           = true
vim.opt.updatetime              = 300
vim.opt.virtualedit             = 'all'
vim.opt.wildmode                = 'longest:full,full'
vim.opt.winblend                = 15
vim.opt.wrap                    = true

-- search
vim.opt.magic                   = true
vim.opt.ignorecase              = true
vim.opt.smartcase               = true

-- fold
vim.opt.foldopen                = "all"
vim.opt.foldclose               = "all"

-- hide EndOfBuffer
vim.opt.fillchars:append('eob: ')

-- win32yank
-- https://github.com/equalsraf/win32yank/releases
-- sudo ln -s /mnt/c/Users/USERNAME/path/to/script/win32yank.exe win32yank.exe
if vim.fn.has("wsl") == 1 then
  if vim.fn.executable("win32yank.exe") == 0 then
    print("wl-clipboard not found, clipboard integration won't work")
  else
    vim.g.clipboard = {
      name = 'myClipboard',
      copy = {
        ["+"] = { 'win32yank.exe', '-i' },
        ["*"] = { 'win32yank.exe', '-i' },
      },
      paste = {
        ["+"] = { 'win32yank.exe', '-o' },
        ["*"] = { 'win32yank.exe', '-o' },
      },
      cache_enabled = 1,
    }
  end
elseif vim.fn.has("linux") == 1 then
  if vim.fn.executable("xsel") == 0 then
    print("wsel not found, clipboard integration won't work")
  else
    vim.g.clipboard = {
      name = 'myClipboard',
      copy = {
        ["+"] = { 'xsel', '-bi' },
        ["*"] = { 'xsel', '-bi' },
      },
      paste = {
        ["+"] = { 'xsel', '-bo' },
        ["*"] = { 'xsel', '-bo' },
      },
      cache_enabled = 1,
    }
  end
end
vim.g.loaded_matchit = 1

-- :ls の出力を解析して判定する関数
function is_blank_screen_by_ls()
  -- :ls コマンドを実行し、出力をキャプチャ (true は出力を返すオプション)
  local ls_output = vim.api.nvim_exec('ls', true)
  -- 出力が取得できなかったり空の場合は false
  if ls_output == nil or ls_output == '' then
    return false
  end
  -- 出力を改行で分割し、前後の空白を除去した非空行のリストを作成
  local lines = {}
  for line in ls_output:gmatch("[^\r\n]+") do
    local trimmed_line = line:match("^%s*(.-)%s*$")
    if trimmed_line and #trimmed_line > 0 then
      table.insert(lines, trimmed_line)
    end
  end
  -- :ls の結果が1行でなければ、ブランク画面（バッファ1つ）ではない
  if #lines ~= 1 then
    return false
  end
  -- 唯一の行を取得
  local line_content = lines[1]
  -- 期待するパターンにマッチするか確認
  local pattern = '"%[No Name%]"'
  if string.match(line_content, pattern) then
    -- パターンに一致すればブランク画面の可能性が高い
    return true
  else
    return false
  end
end

--- https://zenn.dev/kawarimidoll/articles/68f5e8c362ee1c
local function skip_hit_enter(fn, opts)
  opts = opts or {}
  local wait = opts.wait or 0
  return function(...)
    local save_mopt = vim.opt.messagesopt:get()
    vim.opt.messagesopt:append('wait:' .. wait)
    vim.opt.messagesopt:remove('hit-enter')
    fn(...)
    vim.schedule(function()
      vim.opt.messagesopt = save_mopt
    end)
  end
end
if vim.fn.has('vim_starting') == 1 then
  vim.cmd.checkhealth = skip_hit_enter(vim.cmd.checkhealth)
end
