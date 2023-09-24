vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = 'utf-8'
vim.opt.fileformats = 'unix,dos,mac'

vim.opt.backspace = 'start,eol,indent'
vim.opt.clipboard = 'unnamed'
vim.opt.cursorline = true
vim.opt.diffopt = 'internal,filler,algorithm:histogram,indent-heuristic'
vim.opt.display = 'lastline'
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.history = 4096
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.incsearch = true
vim.opt.laststatus = 2
vim.opt.lazyredraw = true
vim.opt.list = true
vim.opt.matchtime = 1
vim.opt.number = true
vim.opt.number = true
vim.opt.ruler = true
vim.opt.secure = true
vim.opt.sh = 'zsh'
vim.opt.shiftwidth = 2
vim.opt.shortmess = 'I'
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.showmode = false
vim.opt.showtabline = 1
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.opt.virtualedit = 'all'
vim.opt.wildmode = 'longest:full,full'
vim.opt.wrap = true
vim.opt.winblend = 15

-- fold
vim.opt.foldopen = "all"
vim.opt.foldclose = "all"

vim.opt.fillchars:append('eob: ') -- suppress ~ at EndOfBuffer.
