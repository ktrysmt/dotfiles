" -----
" vim-lsp
" -----
let g:lsp_async_completion = 1

" log
let g:lsp_log_verbose = 0
let g:lsp_log_file = ""

" lint
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_signs_enabled = 1

" UI
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_virtual_text_enabled = 0
let g:lsp_highlights_enabled = 0
let g:lsp_textprop_enabled = 0
let g:lsp_document_highlight_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0 " to disable A>

augroup VimLspSetting
  autocmd!
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> gd :LspDefinition<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> gv :call OpenDefinitionInSplit()<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> <Leader>n :LspNextDiagnostic<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> <Leader>N :LspPreviousDiagnostic<CR>
  autocmd FileType go,rust,python,ruby,c,cpp,typescript,typescriptreact nnoremap <silent> gh :LspHover<CR>

  if executable('node_modules/.bin/prettier') " aleでやらせる
    autocmd FileType go,rust,python,ruby autocmd BufWritePre <buffer> silent! LspDocumentFormatSync
  else
    autocmd FileType go,rust,python,ruby,typescript,typescriptreact autocmd BufWritePre <buffer> silent! LspDocumentFormatSync
  endif
augroup END

function! OpenDefinitionInSplit()
  execute 'wincmd v'
  execute 'wincmd w'
  execute 'sleep 50m | vert res 1 | LspDefinition'
  " execute 'sleep 50m'
  " execute 'LspDefinition'
  execute 'sleep 400m | wincmd ='
  execute "normal! zz"
endfunction
command! LspDefinitionInSplit call OpenDefinitionInSplit()

setlocal omnifunc=lsp#complete

" ---
" asyncomplete
" ---
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
let g:asyncomplete_auto_completeopt = 0

" ---
" asyncomplete-buffer
" ---
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
   \ 'name': 'buffer',
   \ 'allowlist': ['*'],
   \ 'blocklist': ['go'],
   \ 'completor': function('asyncomplete#sources#buffer#completor'),
   \ 'config': {
   \    'max_buffer_size': 5000000,
   \  },
   \ }))
let g:asyncomplete_log_file = expand('~/.cache/vim/asyncomplete.log')

" ---
" LSP Settings
" ---
" rust
if executable('rust-analyzer')
  augroup VimLsp_RustAnalyzer
    au!
    au User lsp_setup call lsp#register_server({
      \ 'name': 'Rust Language Server',
      \ 'cmd': {server_info->['rust-analyzer']},
      \ 'allowlist': ['rust'],
      \ 'initialization_options': {
      \   'cargo': {
      \     'buildScripts': {
      \       'enable': v:true,
      \     },
      \   },
      \   'procMacro': {
      \     'enable': v:true,
      \   },
      \  },
      \ })
augroup END
endif

" go
if executable('gopls')
  augroup VimLsp_Gopls
    au!
    au User lsp_setup call lsp#register_server({
      \ 'name': 'gopls',
      \ 'cmd': {server_info->['gopls']},
      \ 'allowlist': ['go'],
      \ })
  augroup END
endif
if executable('golangci-lint-langserver')
  augroup VimLsp_GolangciLintLangserver
    au!
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'golangci-lint-langserver',
      \ 'cmd': {server_info->['golangci-lint-langserver']},
      \ 'initialization_options': {'command': ['golangci-lint', 'run', '--enable-all', '--disable', 'lll', '--out-format', 'json', '--issues-exit-code=1']},
      \ 'allowlist': ['go'],
      \ })
  augroup END
endif

" ts
if executable('typescript-language-server')
  augroup VimLsp_TypescriptLauguageServer
    au!
    autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'typescript-language-server',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
      \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
      \ 'allowlist': ['typescript'],
      \ })
  augroup END
endif

" py
if executable('pylsp')
  augroup VimLsp_PythonLspServer
    au!
    au User lsp_setup call lsp#register_server({
      \ 'name': 'pylsp',
      \ 'cmd': {server_info->['pylsp']},
      \ 'allowlist': ['python'],
      \ })
  augroup END
endif

" c/c++
if executable('clangd')
  augroup VimLsp_Clangd
    au!
    au User lsp_setup call lsp#register_server({
      \ 'name': 'clangd',
      \ 'cmd': {server_info->['clangd', '-background-index']},
      \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
      \ })
  augroup END
endif

" ruby
if executable('solargraph')
  augroup VimLsp_Solargraph
    au!
    au User lsp_setup call lsp#register_server({
      \ 'name': 'solargraph',
      \ 'cmd': {server_info->['solargraph', 'stdio']},
      \ 'allowlist': ['ruby'],
      \ })
  augroup END
endif
