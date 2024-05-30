return {
  "github/copilot.vim",
  event = { "CursorHold", "CursorMoved", "ModeChanged", "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    vim.keymap.set('i', '<Tab>', '<Plug>(copilot-accept-word)')

    -- vim.g.copilot_filetypes = {
    --   ["*"] = false,
    --   ["javascript"] = true,
    --   ["typescript"] = true,
    --   ["lua"] = false,
    --   ["rust"] = true,
    --   ["c"] = true,
    --   ["c#"] = true,
    --   ["c++"] = true,
    --   ["go"] = true,
    --   ["python"] = true,
    -- }
  end,
}
