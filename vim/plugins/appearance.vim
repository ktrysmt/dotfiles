" ---
" [colorscheme]
" ---
" set termguicolors
set background=dark

" colorscheme gruvbox-material
colorscheme moonshine_lowcontrast

" highlight Visual ctermbg=52 guibg=#5d4251
" highlight VisualNOS ctermbg=52 guibg=#5d4251
" highlight Visual gui=reverse


" ---
" [illuminate]
" ---
let g:Illuminate_ftblacklist = ['fern']


" ---
" [lightline]
" ---
set laststatus=2
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
"     enable = false,
"   }
" }
" EOF
"
