return {
  'unegunn/fzf.vim',
  cmd = {
     'Commands',
     'GFiles?',
     'Buffers',
     'History',
     'Ripgrep',
     'Windows',
     'Maps',
     'Files',
  },
  config = function()
    vim.g.fzf_layout = { 'down': '~40%' }

    vim.api.nvim_create_user_command(
      'Files',
      'call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)',
      { bang = true, nargs = '?', complete = dir }
    )

  end
}
