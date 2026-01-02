-- vim.opt.cmdheight = 0

local ok, extui = pcall(require, "vim._extui")
if ok then
  extui.enable({
    enable = true,
    target = "box",
    timeout = 4000,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      vim.api.nvim_echo({ { "[" }, { client.name }, { "] Attached" } }, true, {})
    end
  })

  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
      local value = ev.data.params.value
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local status = vim.lsp.status()

      if value.kind == "begin" then
        id = vim.api.nvim_echo({ { "[" }, { client.name }, { "] " }, { value.title } }, true, {})
      elseif value.kind == "end" then
        vim.api.nvim_echo({ { "[" }, { client.name }, { "]" }, { value.title } }, true, {})
      end
    end
  })
end
