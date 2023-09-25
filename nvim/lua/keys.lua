vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- normal mode
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', '<Esc><Esc>', '<cmd>nohlsearch<CR><Esc><C-l>', { silent = true })
vim.keymap.set('n', '<Leader>t', [[<cmd>new | :terminal<CR><insert>]], { silent = true })
vim.keymap.set('n', '<Leader>T', [[<cmd>tabnew | :terminal<CR><insert>]], { silent = true })
vim.keymap.set('n', '<Leader>vt', [[<cmd>vne | :terminal<CR><insert>]], { silent = true })

-- search and replace
-- vim.keymap.set('n', '#', '#N')  -- search and highlight but stay cursor
vim.keymap.set('n', '/', '/\\v')
vim.keymap.set('n', 'x', '"_x') -- only n, not v
vim.keymap.set('n', 's', '"_s')
vim.keymap.set('n', 'cn', '*N"_cgn')
vim.keymap.set('n', 'cN', '*N"_cgN')
vim.keymap.set('n', '<C-g>', "<cmd>echo expand('%:p')<cr>")
vim.cmd [[
function! s:search() abort
  let tmp = @"
  normal! gv""y
  let [text, @"] = [escape(@", '\/'), tmp]
  return '\V' .. substitute(text, "\n", '\\n', 'g')
endfunction
xnoremap <expr> cn "\<Esc>/\<C-r>=<SID>search()\<CR>\<CR>N\"_cgn"
]]
vim.keymap.set('n', '<Leader>p', '"0p', { silent = true })
vim.keymap.set('v', '<Leader>p', '"0p', { silent = true })

-- terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-W>w', '<cmd>wincmd w<cr>')
vim.keymap.set('t', '<C-W>k', '<cmd>wincmd k<cr>')
vim.keymap.set('t', '<C-W>j', '<cmd>wincmd j<cr>')
vim.keymap.set('t', '<C-W>h', '<cmd>wincmd h<cr>')
vim.keymap.set('t', '<C-W>l', '<cmd>wincmd l<cr>')
vim.keymap.set('t', '<C-W>W', '<cmd>wincmd W<cr>')
vim.keymap.set('t', '<C-W>K', '<cmd>wincmd K<cr>')
vim.keymap.set('t', '<C-W>J', '<cmd>wincmd J<cr>')
vim.keymap.set('t', '<C-W>H', '<cmd>wincmd H<cr>')
vim.keymap.set('t', '<C-W>L', '<cmd>wincmd L<cr>')
vim.keymap.set('t', '<C-W>x', '<cmd>wincmd x<cr>')

-- insert mode and commandline mode
vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('i', '<C-e>', '<C-g>U<End>')
vim.keymap.set('c', '<C-f>', '<Right>', { remap = true }) -- use remapped right key by lexima
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set({ 'c', 'i' }, '<C-b>', '<Left>')
vim.keymap.set({ 'c', 'i' }, '<C-t>', '<C-o>w')
vim.keymap.set({ 'c', 'i' }, '<C-d>', '<C-o>b')
vim.keymap.set('c', '<C-a>', '<Home>')
local last_press_time = nil
local threshold = 300
vim.keymap.set("i", "<C-a>", function()
  local current_time = vim.fn.reltimefloat(vim.fn.reltime()) * 1000
  if last_press_time and (current_time - last_press_time < threshold) then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<home>', true, true, true), 'n', true)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>_', true, true, true), 'n', true)
  end
  last_press_time = current_time
end)

-- quickfix
vim.keymap.set('n', '<Leader>co', '<cmd>copen<cr>', { silent = true })
vim.keymap.set('n', '<Leader>cl', '<cmd>cclose<cr>', { silent = true })
vim.keymap.set('n', '<Leader>cc', function()
  qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd "cclose"
    return
  else
    vim.cmd "copen"
    vim.g.qf_exists = true
    return
  end
end
, { silent = true })

-- tab jump
for i = 1, 9 do
  vim.keymap.set('n', string.format('t%d', i), string.format('%dgt', i), { silent = true })
end

-- window jump
for i = 1, 9 do
  vim.keymap.set('n', string.format('<C-w>%d', i), string.format('<C-w>%dw', i), { silent = true })
end

-- move line
-- vim.keymap.set("n", "<A-j>", "<cmd>move .+1<CR>")
-- vim.keymap.set("x", "<A-j>", "<cmd>move '>+1<CR>gv=gv")
-- vim.keymap.set("n", "<A-k>", "<cmd>move .-2<CR>")
-- vim.keymap.set("x", "<A-k>", "<cmd>move '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-j>", '"zdd"zp')
vim.keymap.set("n", "<C-k>", '"zdd<Up>"zP')
vim.keymap.set("v", "<C-j>", '"zx"zp`[V`]')
vim.keymap.set("v", "<C-k>", '"zx<Up>"zP`[V`]')
