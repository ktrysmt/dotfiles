local M = {}

function M.init()
  -- win32yank
  -- https://github.com/equalsraf/win32yank/releases
  -- sudo ln -s /mnt/c/Users/USERNAME/path/to/script/win32yank.exe win32yank.exe
  if vim.fn.has("wsl") == 1 then
    if vim.fn.executable("win32yank.exe") == 0 then
      print("wl-clipboard not found, clipboard integration won't work")
    else
      vim.g.clipboard = {
        name = 'myClipboard',
        copy = {
          ["+"] = { 'win32yank.exe', '-i' },
          ["*"] = { 'win32yank.exe', '-i' },
        },
        paste = {
          ["+"] = { 'win32yank.exe', '-o' },
          ["*"] = { 'win32yank.exe', '-o' },
        },
        cache_enabled = 1,
      }
    end
  elseif vim.fn.has("linux") == 1 then
    if vim.fn.executable("xsel") == 0 then
      print("wsel not found, clipboard integration won't work")
    else
      vim.g.clipboard = {
        name = 'myClipboard',
        copy = {
          ["+"] = { 'xsel', '-bi' },
          ["*"] = { 'xsel', '-bi' },
        },
        paste = {
          ["+"] = { 'xsel', '-bo' },
          ["*"] = { 'xsel', '-bo' },
        },
        cache_enabled = 1,
      }
    end
  end
end

return M
