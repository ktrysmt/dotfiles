lua <<EOF
local ts_config = require "nvim-treesitter.configs"

ts_config.setup {
  ensure_installed = {
    "dockerfile",
    "rust",
    "toml",
    "python",
    "gomod",
    "yaml",
    "graphql",
    "ruby",
    "perl",
    "make",
    "go",
    "svelte",
    "json",
    "vim",
    "cpp",
    "javascript",
    "lua",
    "bash",
    "html",
    "tsx",
    "css",
    "c",
    "typescript",
    "markdown",
    "lua",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  }
}
EOF
