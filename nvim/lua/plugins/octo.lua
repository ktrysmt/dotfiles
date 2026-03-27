return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  event = "VeryLazy",
  opts = {
    picker = "fzf-lua",
    enable_builtin = true,
    use_local_fs = true,
    mappings_disable_default = true,
    mappings = {
      review_diff = {
        select_next_entry = { lhs = "J", desc = "next changed file" },
        select_prev_entry = { lhs = "K", desc = "prev changed file" },
      },
      file_panel = {
        select_next_entry = { lhs = "J", desc = "next changed file" },
        select_prev_entry = { lhs = "K", desc = "prev changed file" },
        select_entry = { lhs = "<cr>", desc = "show selected file diffs" },
      },
    },
  },
  config = function(_, opts)
    require("octo").setup(opts)
    vim.api.nvim_create_user_command("ReviewHelp", function()
      vim.notify(table.concat({
        "PR Review workflow:",
        "  :Octo pr list           -- PR一覧から選択",
        "  :Octo pr checkout <num> -- PRをチェックアウト",
        "  :or                     -- レビュー開始 (diffview)",
        "  J / K                   -- ファイル移動",
        "  <cr>                    -- レビューファイルに遷移",
        "  :oa <localleader>ca     -- カーソル行にインラインコメント",
        "  :oq                     -- クローズ",
      }, "\n"), vim.log.levels.INFO)
    end, {})
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
}
