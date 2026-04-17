return {
  'nvim-treesitter/nvim-treesitter',
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')

    -- nvim-treesitter (main) ships queries that target newer parsers than
    -- the ones bundled in nvim 0.12, so install everything explicitly.
    ts.install({
      "astro",
      "bash",
      "css",
      "dockerfile",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "hcl",
      "html",
      "javascript",
      "json",
      "json5",
      "kotlin",
      "lua",
      "markdown",
      "markdown_inline",
      "mermaid",
      "python",
      "query",
      "rust",
      "sql",
      "svelte",
      "terraform",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
    })

    -- ftplugin is disabled (did_load_ftplugin=1), so manually start treesitter
    -- for filetypes whose bundled ftplugin calls vim.treesitter.start()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "lua", "vim", "vimdoc", "query" },
      callback = function(args)
        vim.treesitter.start(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "astro", "yaml", "yaml.ansible" },
      callback = function(args)
        vim.treesitter.stop(args.buf)
      end,
    })
  end
}
