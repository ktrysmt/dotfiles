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
      vmap v <Plug>(expand_region_expand)
      vmap V <Plug>(expand_region_shrink)
    ]]
  end
}
