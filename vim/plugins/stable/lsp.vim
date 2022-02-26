" -----
" vim-lsp
" -----
let g:lsp_async_completion = 1
" let g:lsp_hover_conceal = 0
" let g:lsp_signature_help_enabled = 0

" floating window with lsp
" let g:lsp_preview_float = 0
" let g:lsp_documentation_float = 0

" lint
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_virtual_text_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_signs_enabled = 1

let g:lsp_highlights_enabled = 0
let g:lsp_textprop_enabled = 0
let g:lsp_document_highlight_enabled = 0

let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
let g:lsp_settings_filetype_typescript = ['typescript-language-server', 'eslint-language-server']

augroup VimLspSetting
  autocmd!
  autocmd FileType go,vim,rust,python,ruby,c,cpp,typescript,typescriptreact nmap gd <Plug>(lsp-definition)
  autocmd FileType go,vim,rust,python,ruby,c,cpp,typescript,typescriptreact nmap gv :rightbelow vertical LspDefinition<CR>
  autocmd FileType go,vim,rust,python,ruby,c,cpp,typescript,typescriptreact nmap <silent> <Leader>n :LspNextDiagnostic<CR>
  autocmd FileType go,vim,rust,python,ruby,c,cpp,typescript,typescriptreact nmap <silent> <Leader>N :LspPreviousDiagnostic<CR>
  autocmd FileType go,vim,rust,python,ruby,c,cpp,typescript,typescriptreact autocmd BufWritePre <buffer> silent! LspDocumentFormatSync
augroup END

let g:lsp_log_verbose = 0
let g:lsp_log_file = ""

setlocal omnifunc=lsp#complete
