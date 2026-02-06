vim.g.mapleader                 = " "
vim.g.maplocalleader            = " "

vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu   = 1
vim.g.did_indent_on             = 1
-- vim.g.did_load_filetypes        = 1
vim.g.did_load_ftplugin         = 1
vim.g.loaded_2html_plugin       = 1
vim.g.loaded_gzip               = 1
vim.g.loaded_man                = 1
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
vim.g.loaded_matchit            = 1
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
vim.opt.autoread                = true
vim.opt.matchpairs:append({
  "<:>",
  "「:」",
  "（:）",
  "『:』",
  "【:】",
  "《:》",
  "〈:〉",
  "｛:｝",
  "［:］",
  "':'",
  '":"'
})


-- search
vim.opt.magic      = true
vim.opt.ignorecase = true
vim.opt.smartcase  = true

-- fold
vim.opt.foldopen   = "all"
vim.opt.foldclose  = "all"

-- hide EndOfBuffer
vim.opt.fillchars:append('eob: ')

-- au
-- should be sync
local ansible_group = vim.api.nvim_create_augroup('ansible_group', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { "*.yaml.j2", "*.yml.j2" },
  group = ansible_group,
  command = "setfiletype yaml.ansible"
})
