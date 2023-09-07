return {
  "elentok/format-on-save.nvim" ,
  event = { "VeryLazy" },
  config = function()
    local format_on_save = require("format-on-save")
    local formatters = require("format-on-save.formatters")

    local ts_formatter = function(formatters)
      if vim.fn.executable('node_modules/.bin/prettier') > 0 then
        return formatters.prettier
      else
        return formatters.lsp
      end
    end

    format_on_save.setup({
      exclude_path_patterns = {
        "/node_modules/",
        ".local/share/nvim/lazy",
      },
      formatter_by_ft = {
        css = formatters.lsp,
        html = formatters.lsp,
        java = formatters.lsp,
        javascript = formatters.lsp,
        json = formatters.lsp,
        lua = formatters.lsp,
        markdown = formatters.lsp,
        openscad = formatters.lsp,
        python = formatters.lsp,
        rust = formatters.lsp,
        scad = formatters.lsp,
        scss = formatters.lsp,
        sh = formatters.shfmt,
        terraform = formatters.lsp,
        go = formatters.lsp,
        vim = formatters.lsp,
        dockerfile = formatters.lsp,

        typescript = ts_formatter(formatters),
        typescriptreact = ts_formatter(formatters),

        javascript = {
          formatters.if_file_exists({
            pattern = ".eslintrc.*",
            formatter = formatters.eslint_d_fix,
          }),
          formatters.if_file_exists({
            pattern = { ".prettierrc", ".prettierrc.*", "prettier.config.*" },
            formatter = formatters.prettierd,
          }),
        },
      },

      fallback_formatter = {
        formatters.remove_trailing_whitespace,
        formatters.remove_trailing_newlines,
      },

      run_with_sh = false,
    })
  end
}
