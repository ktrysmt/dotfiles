" ---
" [colorscheme]
" ---
" set termguicolors
set background=dark
colorscheme moonshine_lowcontrast


" ---
" [illuminate]
" ---
let g:Illuminate_ftblacklist = ['fern']


" ---
" [lightline]
" ---
set laststatus=2
set t_Co=256
if !has('gui_running')
  set t_Co=256
endif
let g:lightline = {
  \'colorscheme': 'wombat',
  \'active': {
  \  'left': [
  \    ['mode', 'paste'],
  \    ['readonly', 'filename', 'modified'],
  \  ]
  \},
  \'component_function': {
  \  'lsp': 'LspNextError'
  \},
\}


" ---
" [treesitter]
" ---
" lua <<EOF
" require "nvim-treesitter.configs".setup {
"   ensure_installed = {
"     "dockerfile",
"     "rust",
"     "toml",
"     "python",
"     "gomod",
"     "yaml",
"     "graphql",
"     "ruby",
"     "perl",
"     "make",
"     "go",
"     "svelte",
"     "json",
"     "vim",
"     "cpp",
"     "javascript",
"     "lua",
"     "bash",
"     "html",
"     "tsx",
"     "css",
"     "c",
"     "typescript",
"     "markdown",
"     "lua",
"   },
"   highlight = {
"     enable = true,
"   }
" }
" EOF
