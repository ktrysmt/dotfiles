return {
  "terryma/vim-expand-region",
  event = "VeryLazy",
  dependencies = {
    "wellle/targets.vim",
    "kana/vim-textobj-user",
    "kana/vim-textobj-line",
    "kana/vim-textobj-entire",
  },
  config = function()
    vim.cmd [[
    let g:expand_region_text_objects = {
    \ 'iw'  :0,
    \ 'iW'  :0,
    \ 'i"'  :0,
    \ 'i''' :0,
    \ 'ia'  :0,
    \ 'i)'  :1,
    \ 'il'  :1,
    \ 'if'  :1,
    \ 'af'  :1,
    \ 'it'  :1,
    \ 'ie'  :0,
    \ }
    ]]
    vim.cmd [[
    vmap v <Plug>(expand_region_expand)
    vmap V <Plug>(expand_region_shrink)
    ]]
  end
}
