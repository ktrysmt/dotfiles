inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

"
" It is forked from https://github.com/prabirshrestha/asyncomplete-neosnippet.vim
"
au User asyncomplete_setup call asyncomplete#register_source({
      \ 'name': 'my_neosnippet',
      \ 'whitelist': ['*'],
      \ 'completor': function('s:my_neosnippet_completor'),
      \ })
function! s:my_neosnippet_completor(opt, ctx) abort
    let l:snips = values(neosnippet#helpers#get_completion_snippets())

    let l:matches = []

    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    " let l:kw = matchstr(l:typed, '\w\+$')
    let l:kw = matchstr(l:typed, '\v\S+$')

    let l:kwlen = len(l:kw)

    let l:matches = map(l:snips,'{"word":v:val["word"],"dup":1,"icase":1,"menu": "Snips: " . v:val["menu_abbr"]}')
    let l:startcol = l:col - l:kwlen

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

"
" prabirshrestha/asyncomplete-buffer.vim
"
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'whitelist': ['*'],
    \ 'blacklist': ['go'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ 'config': {
    \    'max_buffer_size': -1,
    \  },
    \ }))

