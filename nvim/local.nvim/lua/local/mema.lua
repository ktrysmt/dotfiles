--- mema.nvim - Markdown Mermaid preview plugin for Neovim
--
-- Usage:
--   :MemaPreview [position]  - Preview current buffer with Mermaid diagrams as ASCII art
--   :MemaClose               - Close the preview buffer
--   :MemaToggle [position]   - Toggle preview window
--
-- Options:
--   vim.g.mema_auto_update   - Auto-update preview on buffer write (default: false)
--   vim.g.mema_preview_position - Default position: 'right', 'left', 'below', 'above' (default: 'right')

local M = {}

local PREVIEW_BUFFER_NAME = '__mema_preview__'
local PREVIEW_FOLDED_NAME = '════ Mermaid Preview ════'

-- Get mema script path (assumes plugin is in same directory)
local function get_mema_path()
  -- Try multiple possible locations for main.js
  local candidates = {
    vim.fn.getcwd() .. '/main.js',
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:h') .. '/main.js',
    debug.getinfo(1, 'S').source:sub(2):gsub('/lua/mema%.lua$', '') .. '/main.js',
  }

  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end

  return nil
end

-- Get config value with fallback to default
local function get_config(key, default)
  local val = vim.g['mema_' .. key]
  if val == nil then
    return default
  end
  return val
end

-- Get preview buffer if it exists
local function get_preview_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == PREVIEW_BUFFER_NAME then
      return bufnr
    end
  end
  return nil
end

-- Get original buffer for a preview buffer
local function get_original_buffer(bufnr)
  if bufnr == nil then
    return nil
  end
  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  if ft == 'mema-preview' then
    return vim.api.nvim_buf_get_number(vim.api.nvim_buf_get_option(bufnr, 'bufhidden'))
  end
  return nil
end

-- Create or get preview buffer
local function create_preview_buffer()
  local existing = get_preview_buffer()
  if existing then
    return existing, false
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(bufnr, 'buflisted', false)
  vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'mema-preview')
  vim.api.nvim_buf_set_name(bufnr, PREVIEW_BUFFER_NAME)

  -- Store reference to original buffer in bufoption
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'hide')

  -- Set up local mappings
  vim.keymap.set('n', 'q', '<Cmd>bd<CR>', { buffer = bufnr, silent = true, desc = 'Close preview' })
  vim.keymap.set('n', '<Esc>', '<Cmd>bd<CR>', { buffer = bufnr, silent = true, desc = 'Close preview' })

  return bufnr, true
end

-- Open preview window with position control
local function open_preview_window(bufnr, position)
  local current_win = vim.api.nvim_get_current_win()

  -- Determine command based on position
  local cmd = 'vsplit'
  if position == 'left' then
    cmd = 'topleft vsplit'
  elseif position == 'below' then
    cmd = 'botright split'
  elseif position == 'above' then
    cmd = 'topleft split'
  end

  vim.cmd(cmd)
  vim.api.nvim_set_current_buf(bufnr)

  -- If opening on left/above, move back to original window
  if position == 'left' or position == 'above' then
    vim.api.nvim_set_current_win(current_win)
  end
end

-- Close preview window and return to original window
local function close_preview_window()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

  if ft == 'mema-preview' then
    -- Try to switch back to original window
    local win_id = vim.api.nvim_get_current_win()
    local info = vim.fn.getwininfo(win_id)
    -- Find a non-preview window to switch to
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local win_buf = vim.api.nvim_win_get_buf(win)
      local win_ft = vim.api.nvim_buf_get_option(win_buf, 'filetype')
      if win_ft ~= 'mema-preview' then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
    return true
  end
  return false
end

-- Render preview content
local function render_preview(content, position)
  if content == '' then
    print('mema: buffer is empty')
    return
  end

  local mema_path = get_mema_path()
  if not mema_path then
    print('mema: main.js not found. Make sure it is in your project directory.')
    return
  end

  -- Run mema with content via stdin
  local cmd = 'mema 2>&1'
  local output = vim.fn.system(cmd, content)

  -- Check for errors
  if vim.v.shell_status ~= 0 then
    print('mema: ' .. output)
    return
  end

  -- Split output into lines
  local lines = vim.split(output, '\n')

  -- Remove empty lines at the end
  while #lines > 0 and lines[#lines] == '' do
    table.remove(lines)
  end

  local bufnr, is_new = create_preview_buffer()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

  if is_new then
    open_preview_window(bufnr, position)
  end

  -- Set up auto-update on buffer write if enabled
  if get_config('auto_update', false) then
    vim.api.nvim_buf_call(0, function()
      vim.cmd('autocmd BufWritePost <buffer> MemaPreview')
    end)
  end
end

-- :MemaPreview command
M.preview = function(opts)
  local position = 'right'
  if opts.args ~= '' then
    position = opts.args
  end

  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  content = table.concat(content, '\n')

  render_preview(content, position)
end

-- :MemaClose command
M.close_preview = function()
  close_preview_window()
end

-- :MemaToggle command
M.toggle = function(opts)
  local preview_buf = get_preview_buffer()
  local position = 'right'
  if opts.args ~= '' then
    position = opts.args
  end

  if preview_buf then
    -- Preview exists, close it
    local current_buf = vim.api.nvim_get_current_buf()
    if current_buf == preview_buf then
      close_preview_window()
    else
      -- Find the window with preview buffer
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == preview_buf then
          vim.api.nvim_set_current_win(win)
          close_preview_window()
          break
        end
      end
    end
  else
    -- Preview doesn't exist, open it
    local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    content = table.concat(content, '\n')
    render_preview(content, position)
  end
end

-- Initialize plugin
M.init = function()
  -- Create commands
  vim.api.nvim_create_user_command('MemaPreview', M.preview, {
    desc = 'Preview markdown with Mermaid ASCII art',
    nargs = '?',
    complete = 'file',
  })
  vim.api.nvim_create_user_command('MemaClose', M.close_preview, {
    desc = 'Close mema preview buffer',
  })
  vim.api.nvim_create_user_command('MemaToggle', M.toggle, {
    desc = 'Toggle mema preview window',
    nargs = '?',
    complete = 'file',
  })
end

return M
