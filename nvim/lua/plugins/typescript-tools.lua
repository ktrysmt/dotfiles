return {
  "pmizio/typescript-tools.nvim",
  ft = { "typescript", "typescriptreact", "tsx" },
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  build = "npm i -g typescript @styled/typescript-styled-plugin typescript-styled-plugin",
  opts = {},
  config = function()
    require("typescript-tools").setup {}
  end
}
