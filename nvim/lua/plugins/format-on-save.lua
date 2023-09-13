return {
  "elentok/format-on-save.nvim",
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

    local js_formatter = function()
      if vim.api.nvim_buf_get_name(0):match("^.eslintrc.*$") then
        return formatters.eslint_d_fix
      elseif vim.api.nvim_buf_get_name(0):match("^(.prettierrc|.prettierrc.*|prettier.config.*)$") then
        return formatters.prettierd
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
        json = formatters.lsp,
        lua = formatters.lsp,
        markdown = formatters.marksman,
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
        c = formatters.lsp,
        cpp = formatters.lsp,

        typescript = ts_formatter(formatters),
        typescriptreact = js_formatter(formatters),

        javascript = js_formatter(formatters),
      },

      fallback_formatter = {
        formatters.remove_trailing_whitespace,
        formatters.remove_trailing_newlines,
      },

      run_with_sh = false,
    })
  end
}
