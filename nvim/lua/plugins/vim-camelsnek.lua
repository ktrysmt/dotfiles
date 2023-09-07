return {
  'nicwest/vim-camelsnek',
  cmd = {
    "Pascal",
    "Camel",
    "CamelB",
    "Kebab",
    "Snake",
    "Snakecaps",
    "Snek",
    "Screm",
  },
  config = function()
    vim.api.nvim_create_user_command('Pascal', ':CamelB', {})
    vim.api.nvim_create_user_command('Lcamel', ':CamelB', {})
  end
}
