-- Switch IME to ASCII on InsertLeave so Normal-mode keys aren't eaten.
--   macOS: `brew install daipeihust/tap/im-select`
--   WSL:   /mnt/c/tools/im-select.exe (installed by install/ubuntu/wsl.sh)
local M = {}

local function is_wsl()
  local uname = vim.loop.os_uname()
  return uname.sysname == "Linux"
      and uname.release:lower():find("microsoft", 1, true) ~= nil
end

local function resolve_command()
  local sys = vim.loop.os_uname().sysname
  if sys == "Darwin" then
    if vim.fn.executable("im-select") == 0 then return nil end
    return { "im-select", "com.apple.keylayout.ABC" }
  end
  if is_wsl() then
    local exe = "/mnt/c/tools/im-select.exe"
    if vim.fn.filereadable(exe) == 0 then return nil end
    return { exe, "1033" }
  end
  return nil
end

function M.init()
  local cmd = resolve_command()
  if not cmd then return end

  local group = vim.api.nvim_create_augroup("im_select_group", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    pattern = "*",
    callback = function()
      vim.fn.jobstart(cmd, { detach = true })
    end,
    desc = "Switch IME to ASCII when leaving Insert mode",
  })
end

return M
