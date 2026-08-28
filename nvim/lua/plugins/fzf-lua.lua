-- fzf-lua calls `serverstart("fzf-lua." .. os.time())` at require time.
-- Neovim appends ".<pid>.<seq>" and prefixes stdpath("run"), which on macOS is
-- $TMPDIR/nvim.<user> (~78 bytes here). The result exceeds the 104 byte sun_path
-- limit for unix sockets, so serverstart() fails with EINVAL and every module
-- requiring fzf-lua (octo.nvim's picker) errors out at startup.
-- Claim g:fzf_lua_server first with a short name so fzf-lua skips its own call.
return {
  "ibhagwan/fzf-lua",
  init = function()
    if vim.g.fzf_lua_server then
      return
    end
    local ok, srv = pcall(vim.fn.serverstart, "fzf")
    if ok then
      vim.g.fzf_lua_server = srv
    end
  end,
}
