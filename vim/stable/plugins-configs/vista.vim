nmap <C-q> :Vista!!<CR>

let g:vista_default_executive = 'ctags'

let g:vista_executive_for = {
  \ 'python': 'vim_lsp',
  \ 'go': 'vim_lsp',
  \ 'vim': '',
  \ 'typescript': 'vim_lsp',
  \ 'typescriptreact': 'vim_lsp',
  \ 'rust': 'vim_lsp',
  \ }

let g:vista_sidebar_width = 48

let g:vista#renderer#enable_icon = 0

let g:vista_fzf_preview = ['right:50%']

