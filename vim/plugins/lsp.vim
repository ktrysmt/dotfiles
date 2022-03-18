" -----
" vim-lsp
" -----
let g:lsp_async_completion = 1

" lint
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_signs_enabled = 1

let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_virtual_text_enabled = 0
let g:lsp_highlights_enabled = 0
let g:lsp_textprop_enabled = 0
let g:lsp_document_highlight_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0 " to disable A>

let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
let g:lsp_settings_filetype_typescript = ['typescript-language-server']

augroup VimLspSetting
  autocmd!
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> gd :LspDefinition<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> gv :rightbelow vertical LspDefinition<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> <Leader>n :LspNextDiagnostic<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> <Leader>N :LspPreviousDiagnostic<CR>

  if executable('node_modules/.bin/prettier') " aleでやらせる
    autocmd FileType go,rust,python,ruby,c,cpp autocmd BufWritePre <buffer> silent! LspDocumentFormatSync
  else
    autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact autocmd BufWritePre <buffer> silent! LspDocumentFormatSync
  endif

augroup END

let g:lsp_log_verbose = 0
let g:lsp_log_file = ""

setlocal omnifunc=lsp#complete

" ---
" asyncomplete
" ---
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

let g:asyncomplete_auto_completeopt = 0


" prabirshrestha/asyncomplete-buffer.vim
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ 'config': {
    \    'max_buffer_size': -1,
    \  },
    \ }))


