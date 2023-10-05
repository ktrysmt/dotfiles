return {
  'monaqa/dial.nvim',
  keys = {
    { "<C-a>",  mode = "n" },
    { "<C-x>",  mode = "n" },
    { "g<C-a>", mode = "n" }, -- auto increment with dot repeat or v/v-block
    { "g<C-x>", mode = "n" },
  },
  config = function()
    vim.keymap.set("n", "<C-a>", function()
      require("dial.map").manipulate("increment", "normal")
    end)
    vim.keymap.set("n", "<C-x>", function()
      require("dial.map").manipulate("decrement", "normal")
    end)
    vim.keymap.set("n", "g<C-a>", function()
      require("dial.map").manipulate("increment", "gnormal")
    end)
    vim.keymap.set("n", "g<C-x>", function()
      require("dial.map").manipulate("decrement", "gnormal")
    end)

    local augend = require("dial.augend")
    require("dial.config").augends:register_group {
      -- default augends used when no group name is specified
      default = {
        augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex,      -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        -- augend.constant.alias.bool,    -- boolean value (true <-> false)
        augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
        -- uppercase hex number (0x1A1A, 0xEEFE, etc.)
        augend.constant.new {
          elements = { "and", "or" },
          word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
          cyclic = true, -- "or" is incremented into "and".
        },
        augend.constant.new {
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        },
        augend.constant.new {
          elements = { "true", "false" },
          word = false,
          cyclic = true,
          preserve_case = true,
        },
        augend.case.new {
          types = {
            "camelCase",
            "snake_case",
            "PascalCase",
            "kebab-case",
            "SCREAMING_SNAKE_CASE",
          },
          cyclic = true,
        },
      },
    }
  end
}
