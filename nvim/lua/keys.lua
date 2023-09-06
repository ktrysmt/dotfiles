vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- move
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
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- search
vim.keymap.set('n', '/', '/\\v')
vim.keymap.set('n', 'cn', '*N"_cgn')
vim.keymap.set('n', 'cN', '*N"_cgN')
vim.keymap.set('n', '<C-g>', "<cmd>echo expand('%:p')<cr>")

-- paste
vim.keymap.set('n', '<Leader>p',  '"0p', { silent = true })
vim.keymap.set('v', '<Leader>p',  '"0p', { silent = true })

-- in terminal mode
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>')
vim.keymap.set('n', '<ESC><ESC>', '<cmd>nohlsearch<CR><ESC>', { silent = true })
vim.keymap.set('n', '<Leader>t ', '<cmd>new \\| :terminal<CR><insert>', { silent = true })
vim.keymap.set('n', '<Leader>T ', '<cmd>tabnew \\| :terminal<CR><insert>', { silent = true })
vim.keymap.set('n', '<Leader>vt', '<cmd>vne \\| :terminal<CR><insert>', { silent = true })

-- move in insert mode
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-c>', '<ESC>')

-- use it later...
vim.keymap.set('n', '<c-j>', '<Nop>')
vim.keymap.set('i', '<c-j>', '<Nop>')
vim.keymap.set('v', '<c-j>', '<Nop>')
vim.keymap.set('n', '<c-k>', '<Nop>')
vim.keymap.set('i', '<c-k>', '<Nop>')
vim.keymap.set('v', '<c-k>', '<Nop>')

-- disable select mode...
vim.keymap.set('n', '<c-k>', '<Nop>')
vim.keymap.set('n', '<c-k>', '<Nop>')
vim.keymap.set('n', '<c-k>', '<Nop>')
vim.keymap.set('n', '<c-k>', '<Nop>')

-- quick fix
vim.keymap.set('n', '<Leader>co',  '<cmd>copen<cr>', { silent = true })
vim.keymap.set('n', '<Leader>cl',  '<cmd>cclose<cr>', { silent = true })
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

-- tab jumping
for i = 1, 9 do
  vim.keymap.set('n', string.format('t%d',i), string.format('%dgt',i), { silent = true })
end

-- move line
vim.keymap.set("n", "<C-j>", "<cmd>move .+1<CR>")
vim.keymap.set("x", "<C-j>", "<cmd>move '>+1<CR>gv=gv")
vim.keymap.set("n", "<C-k>", "<cmd>move .-2<CR>")
vim.keymap.set("x", "<C-k>", "<cmd>move '<-2<CR>gv=gv")
