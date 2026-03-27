return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  event = "VeryLazy",
  opts = {
    picker = "fzf-lua",
    enable_builtin = true,
  },
  config = function(_, opts)
    require("octo").setup(opts)
    vim.api.nvim_create_user_command("ReviewHelp", function()
      vim.notify(table.concat({
        "PR Review workflow:",
        "  :Octo pr list              -- PR一覧から選択",
        "  :Octo pr checkout <num>    -- PRをチェックアウト",
        "  :Octo review start         -- レビュー開始 (diffview)",
        "  <localleader>ca            -- カーソル行にインラインコメント",
        "  <localleader>sa            -- カーソル行にサジェスト",
        "  :Octo review submit        -- レビュー送信 (submit)",
        "",
        "Shortcuts:",
        "  :ReviewStart <num>         -- PR開く + レビュー開始",
      }, "\n"), vim.log.levels.INFO)
    end, {})

    -- :ReviewStart <pr_number> - checkout PR and start review
    vim.api.nvim_create_user_command("ReviewStart", function(args)
      local pr_number = args.fargs[1]
      if not pr_number then
        vim.notify("Usage: ReviewStart <pr_number>", vim.log.levels.ERROR)
        return
      end
      vim.cmd("Octo pr edit " .. pr_number)
      vim.defer_fn(function()
        vim.cmd("Octo review start")
      end, 2000)
    end, { nargs = 1 })

  end,
  keys = {
    {
      "<leader>oi",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>op",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>od",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>on",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>os",
      function()
        require("octo.utils").create_base_search_command { include_current_repo = true }
      end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
}
