local M = {}

function M.init()
  --- https://zenn.dev/kawarimidoll/articles/68f5e8c362ee1c
  local function skip_hit_enter(fn, opts)
    opts = opts or {}
    local wait = opts.wait or 0
    return function(...)
      local save_mopt = vim.opt.messagesopt:get()
      vim.opt.messagesopt:append('wait:' .. wait)
      vim.opt.messagesopt:remove('hit-enter')
      fn(...)
      vim.schedule(function()
        vim.opt.messagesopt = save_mopt
      end)
    end
  end
  if vim.fn.has('vim_starting') == 1 then
    vim.cmd.checkhealth = skip_hit_enter(vim.cmd.checkhealth)
  end
end

return M
