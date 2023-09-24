return {
  'preservim/vim-markdown',
  ft = {
    'markdown'
  },
  dependencies = {
    'godlygeek/tabular',
  },
  config = function()
    vim.g.vim_markdown_folding_disabled = 1
    vim.g.vim_markdown_auto_insert_bullets = 1
    vim.g.vim_markdown_new_list_item_indent = 2
  end
}
