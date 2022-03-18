" ---
" [colorscheme]
" ---
colorscheme moonshine_lowcontrast

" set termguicolors
" set background=dark
" let g:gruvbox_material_background = 'hard'
" " let g:gruvbox_material_visual = 'green background'
" autocmd ColorScheme * highlight Visual ctermbg=52 guibg=#5d4251
" colorscheme gruvbox-material


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
"     enable = true,
"   }
" }
" EOF
"
