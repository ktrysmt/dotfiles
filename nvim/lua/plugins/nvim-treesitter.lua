return {
  'nvim-treesitter/nvim-treesitter',
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')

    ts.install({
      "astro",
      "css",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "hcl",
      "json",
      "json5",
      "markdown",
      "markdown_inline",
      "mermaid",
      "svelte",
      "terraform",
      "dockerfile",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "kotlin",
      "lua",
      "python",
      "rust",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "astro", "yaml", "yaml.ansible" },
      callback = function(args)
        vim.treesitter.stop(args.buf)
      end,
    })
  end
}
