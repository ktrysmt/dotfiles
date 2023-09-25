return {
  'mfussenegger/nvim-ansible',
  ft = { 'yaml.ansible' },
  config = function()
    local j2_group = vim.api.nvim_create_augroup('j2_group', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
      pattern = { "*.yaml.j2", "*.yml.j2" },
      group = j2_group,
      command = "setfiletype yaml.ansible"
    })
  end
}
