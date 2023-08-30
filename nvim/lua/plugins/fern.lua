return {
  'lambdalisue/fern.vim',
  keys = {
    { "<C-e>", ":Fern . -reveal=% -drawer -toggle -width=50<CR>", silent = true},
    { '<C-w>f', ":cd `git rev-parse --show-toplevel`<CR> :Fern . -reveal=% -drawer -width=50<CR>", noremap = true, silent = true }
  },
  config = function()
    vim.g["fern#opener"] = "vsplit"
    vim.g["fern#default_hidden"] = 1
    vim.g["fern#default_exclude"] = ".DS_Store"
    vim.g["fern#disable_drawer_hover_popup"] = 1
    vim.g["fern_disable_startup_warnings"] = 1

    local function init_fern()
      local o = { buffer = true, remap = true }
      vim.keymap.set('n', 's', '<Plug>(fern-action-open:vsplit)', o)
      vim.keymap.set('n', 'o', '<Plug>(fern-action-open-or-expand)', o)
      vim.keymap.set('n', 't', '<Plug>(fern-action-open:tabedit)', o)
      vim.keymap.set('n', 'T', '<Plug>(fern-action-open:tabedit)<cmd>gT', o)
      vim.keymap.set('n', 'i', '<Plug>(fern-action-open:split)', o)
      vim.keymap.set('n', 'gi', '<Plug>(fern-action-open:split)<cmd><C-w>p', o)

      vim.cmd([[
        nmap <buffer> <Plug>(fern-my-leave-and-tcd) <Plug>(fern-action-leave)<Plug>(fern-wait)<Plug>(fern-action-tcd:root)
        nmap <buffer> u <Plug>(fern-my-leave-and-tcd)
        nmap <buffer><expr>
          \ <Plug>(fern-my-expand-or-collapse)
          \ fern#smart#leaf(
          \   "\<Plug>(fern-action-collapse)",
          \   "\<Plug>(fern-action-expand:stay)",
          \   "\<Plug>(fern-action-collapse)",
          \ )
        nmap <buffer>
          \ <Plug>(fern-action-expand)
          \ <Plug>(fern-my-expand-or-collapse)
      ]])
    end

    local fern_group = vim.api.nvim_create_augroup('fern_group', { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fern",
      group = fern_group,
      callback = init_fern,
    })
  end,
}
