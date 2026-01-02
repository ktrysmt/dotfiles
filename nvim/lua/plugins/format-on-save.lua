return {
  "elentok/format-on-save.nvim",
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    local format_on_save = require("format-on-save")
    local formatters = require("format-on-save.formatters")

    local js_formatter = function(f)
      if vim.fn.executable('node_modules/.bin/prettier') > 0 or vim.api.nvim_buf_get_name(0):match("^(.prettierrc|.prettierrc.*|prettier.config.*)$") then
        return f.prettierd
      elseif vim.api.nvim_buf_get_name(0):match("^.eslintrc.*$") then
        return f.eslint_d_fix
      else
        return f.lsp
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
        -- json = formatters.lsp,
        lua = formatters.lsp,
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

        typescript = js_formatter(formatters),
        typescriptreact = js_formatter(formatters),

        javascript = js_formatter(formatters),
        javascriptreact = js_formatter(formatters),
      },

      run_with_sh = false,
    })
  end
}
