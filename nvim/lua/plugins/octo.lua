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
    -- Workaround: submit pending review via REST API when GraphQL fails
    -- Usage: :ReviewSubmit <pr_number> <comment|approve|request> [body]
    local event_map = { comment = "COMMENT", approve = "APPROVE", request = "REQUEST_CHANGES" }
    vim.api.nvim_create_user_command("ReviewSubmit", function(args)
      local pr_number = args.fargs[1]
      local event_key = args.fargs[2] or "comment"
      local event = event_map[event_key]
      if not pr_number or not event then
        vim.notify("Usage: ReviewSubmit <pr_number> <comment|approve|request> [body]", vim.log.levels.ERROR)
        return
      end
      local body = table.concat(vim.list_slice(args.fargs, 3), " ")
      local remote = vim.fn.system("gh repo view --json nameWithOwner -q .nameWithOwner"):gsub("%s+$", "")
      local review_id = vim.fn.system(
        ("gh api repos/%s/pulls/%s/reviews --jq '.[] | select(.state == \"PENDING\") | .id'"):format(remote, pr_number)
      ):gsub("%s+$", "")
      if review_id == "" then
        vim.notify("No pending review found for PR #" .. pr_number, vim.log.levels.WARN)
        return
      end
      local cmd = ("gh api repos/%s/pulls/%s/reviews/%s/events -f event=%s"):format(remote, pr_number, review_id, event)
      if body ~= "" then
        cmd = cmd .. " -f body=" .. vim.fn.shellescape(body)
      end
      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        vim.notify(("Review submitted: %s on PR #%s"):format(event_key, pr_number), vim.log.levels.INFO)
      else
        vim.notify("Failed to submit review: " .. result, vim.log.levels.ERROR)
      end
    end, { nargs = "+", complete = function(_, line)
      local args = vim.split(line, "%s+")
      if #args == 3 then return { "comment", "approve", "request" } end
      return {}
    end })

    vim.api.nvim_create_user_command("ReviewHelp", function()
      vim.notify(table.concat({
        "PR Review workflow:",
        "  :Octo pr list              -- PR一覧から選択",
        "  :Octo pr checkout <num>    -- PRをチェックアウト",
        "  :Octo review start         -- レビュー開始 (diffview)",
        "  <localleader>ca            -- カーソル行にインラインコメント",
        "  <localleader>sa            -- カーソル行にサジェスト",
        "  :ReviewSubmit <num> comment|approve|request [body]",
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
