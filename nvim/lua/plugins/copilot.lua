return {
  "github/copilot.vim",
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    vim.keymap.set('i', '<Tab>', '<Plug>(copilot-accept-word)')
  end,
}
