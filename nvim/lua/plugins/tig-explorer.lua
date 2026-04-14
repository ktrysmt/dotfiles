return {
  'iberianpig/tig-explorer.vim',
  keys = {
    { "<Leader>gt", mode = "n" },
    { "<Leader>gT", mode = "n" },
    { "<Leader>gf", mode = "n" },
  },
  event = { 'CmdlineEnter', 'CmdwinEnter' },
  config = function()
    local o = { silent = true }

    vim.cmd [[
    function! g:VsplitRight(...) abort
      let save_splitright = &splitright
      set splitright
      execute 'vsplit' (a:0 > 0 ? a:1 : '')
      let &splitright = save_splitright
    endfunction
    command! -nargs=? -complete=file Vsr call g:VsplitRight(<f-args>)
    ]]

    local function vsr_exec(cmd)
      local save = vim.o.splitright
      vim.o.splitright = true
      vim.cmd("vsplit")
      vim.o.splitright = save
      vim.cmd(cmd)
    end

    vim.keymap.set("n", "<Leader>gt", function()
      vsr_exec("Tig -- " .. vim.fn.getcwd())
    end, o)
    vim.keymap.set("n", "<Leader>gT", function()
      vsr_exec("TigOpenProjectRootDir")
    end, o)
    vim.keymap.set("n", "<Leader>gf", function()
      vsr_exec("TigOpenCurrentFile")
    end, o)
  end
}
