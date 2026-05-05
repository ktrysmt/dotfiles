-- Switch IME to ASCII on InsertLeave so Normal-mode keys aren't eaten.
--   macOS: `brew install daipeihust/tap/im-select`
--   WSL:   im-select.exe (installed by install/ubuntu/wsl.sh)
local M = {}

-- Paths / IDs are extracted here so they're easy to override per environment.
local WSL_EXE = "/mnt/c/tools/im-select.exe" -- must match install/ubuntu/wsl.sh
local WSL_ASCII_ID = "1033"                  -- en-US keyboard layout
local MAC_ASCII_ID = "com.apple.keylayout.ABC"

local function is_wsl()
  local uname = vim.loop.os_uname()
  return uname.sysname == "Linux"
      and uname.release:lower():find("microsoft", 1, true) ~= nil
end

local function resolve_command()
  local sys = vim.loop.os_uname().sysname
  if sys == "Darwin" then
    if vim.fn.executable("im-select") == 0 then return nil end
    return { "im-select", MAC_ASCII_ID }
  end
  if is_wsl() then
    if vim.fn.filereadable(WSL_EXE) == 0 then return nil end
    return { WSL_EXE, WSL_ASCII_ID }
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
