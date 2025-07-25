return {
  -- If you want neo-tree's file operations to work with LSP (updating imports, etc.), you can use a plugin like
  -- https://github.com/antosha417/nvim-lsp-file-operations:
  -- {
  --   "antosha417/nvim-lsp-file-operations",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-neo-tree/neo-tree.nvim",
  --   },
  --   config = function()
  --     require("lsp-file-operations").setup()
  --   end,
  -- },
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- branch = "v3.x",
    -- lazy = false,
    -- event = { "VeryLazy" },
    event = { "VimEnter" },
    keys = {
      { "<C-e>",  mode = 'n' },
      { '<C-w>f', mode = 'n' },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- { "3rd/image.nvim", opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
      -- {
      --   "s1n7ax/nvim-window-picker",   -- for open_with_window_picker keymaps
      --   version = "2.*",
      --   config = function()
      --     require("window-picker").setup({
      --       filter_rules = {
      --         include_current_win = false,
      --         autoselect_one = true,
      --         -- filter using buffer options
      --         bo = {
      --           -- if the file type is one of following, the window will be ignored
      --           filetype = { "neo-tree", "neo-tree-popup", "notify" },
      --           -- if the buffer type is one of following, the window will be ignored
      --           buftype = { "terminal", "quickfix" },
      --         },
      --       },
      --     })
      --   end,
      -- },
    },
    -----Instead of using `config`, you can use `opts` instead, if you'd like:
    -----@module "neo-tree"
    -----@type neotree.Config
    --opts = {},
    config = function()
      local utils = require("neo-tree.utils")
      -- If you want icons for diagnostic errors, you'll need to define them somewhere.
      -- In Neovim v0.10+, you can configure them in vim.diagnostic.config(), like:
      --
      -- vim.diagnostic.config({
      --   signs = {
      --     text = {
      --       [vim.diagnostic.severity.ERROR] = '',
      --       [vim.diagnostic.severity.WARN] = '',
      --       [vim.diagnostic.severity.INFO] = '',
      --       [vim.diagnostic.severity.HINT] = '󰌵',
      --     },
      --   }
      -- })
      --
      -- In older versions, you can define the signs manually:
      vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })



      local function natural_sort(a, b)
        local function tonumber_if_possible(s)
          local num = tonumber(s)
          if num then
            return num
          else
            return s
          end
        end

        local function split_by_number(s)
          local parts = {}
          local current_part = ""
          for i = 1, #s do
            local char = s:sub(i, i)
            if char:match("%d") then
              if current_part ~= "" and not current_part:match("%d") then
                table.insert(parts, current_part)
                current_part = ""
              end
            else
              if current_part ~= "" and current_part:match("%d") then
                table.insert(parts, tonumber(current_part))
                current_part = ""
              end
            end
            current_part = current_part .. char
          end
          if current_part ~= "" then
            table.insert(parts, tonumber_if_possible(current_part))
          end
          return parts
        end

        local parts_a = split_by_number(a.path)
        local parts_b = split_by_number(b.path)

        local len_a = #parts_a
        local len_b = #parts_b
        local min_len = math.min(len_a, len_b)

        for i = 1, min_len do
          local part_a = parts_a[i]
          local part_b = parts_b[i]

          if type(part_a) == "number" and type(part_b) == "number" then
            if part_a ~= part_b then
              return part_a < part_b
            end
          elseif part_a ~= part_b then
            return tostring(part_a) < tostring(part_b)
          end
        end

        return len_a < len_b
      end


      require("neo-tree").setup({
        close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
        -- popup_border_style = "rounded",
        enable_git_status = true,
        use_popups_for_input = false,
        enable_diagnostics = true,
        open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
        open_files_using_relative_paths = false,
        sort_case_insensitive = true,                                      -- used when sorting files and directories in the tree
        -- sort_function = nil,                                               -- use a custom function for sorting files and directories in the tree
        sort_function = function(a, b)
          if a.type ~= b.type then
            return a.type < b.type
          else
            return natural_sort(a, b)
          end
        end,
        -- sort_function = function (a,b)
        --       if a.type == b.type then
        --           return a.path > b.path
        --       else
        --           return a.type > b.type
        --       end
        --   end , -- this sorts files and directories descendantly
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰜌",
            provider = function(icon, node, _) -- default icon provider utilizes nvim-web-devicons if available
              if node.type == "file" or node.type == "terminal" then
                local success, web_devicons = pcall(require, "nvim-web-devicons")
                local name = node.type == "terminal" and "terminal" or node.name
                if success then
                  local devicon, hl = web_devicons.get_icon(name)
                  icon.text = devicon or icon.text
                  icon.highlight = hl or icon.highlight
                end
              end
            end,
            -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
            -- then these will never be used.
            default = "*",
            highlight = "NeoTreeFileIcon",
          },
          modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              -- Change type
              added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
              modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
              deleted = "D", -- this can only be used in the git_status source
              renamed = "󰁕", -- this can only be used in the git_status source
              -- Status type
              untracked = "",
              ignored = "",
              unstaged = "*",
              staged = "+",
              conflict = "x",
            },
          },
          -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
          file_size = {
            enabled = true,
            width = 12,          -- width of the column
            required_width = 64, -- min width of window required to show this column
          },
          type = {
            enabled = true,
            width = 10,           -- width of the column
            required_width = 122, -- min width of window required to show this column
          },
          last_modified = {
            enabled = true,
            width = 20,          -- width of the column
            required_width = 88, -- min width of window required to show this column
          },
          created = {
            enabled = true,
            width = 20,           -- width of the column
            required_width = 110, -- min width of window required to show this column
          },
          symlink_target = {
            enabled = false,
          },
        },
        -- A list of functions, each representing a global custom command
        -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
        -- see `:h neo-tree-custom-commands-global`
        commands = {
          trash = function(state)
            local inputs = require("neo-tree.ui.inputs")
            local path = state.tree:get_node().path
            local _, name = utils.split_path(path)

            local msg = string.format("Are you sure you want to trash '%s'? (y/n) ", name)
            inputs.confirm(msg, function(confirmed)
              if not confirmed then
                return
              end

              vim.fn.system({
                "trash",
                path
              })

              require("neo-tree.sources.manager").refresh(state.name)
            end)
          end,
        },
        window = {
          position = "left",
          width = 50,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<space>"] = {
              "toggle_node",
              nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
            },
            ["<2-LeftMouse>"] = "open",
            ["o"] = "open",                -- "open",
            ["O"] = "expand_all_subnodes", -- "open",
            ["<cr>"] = "open",             -- "open",
            ["<esc>"] = "cancel",          -- close preview or floating neo-tree window
            ["q"] = "cancel",              -- close preview or floating neo-tree window
            ["P"] = "noop",                -- { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
            ["l"] = "noop",                --  "focus_preview",
            ["i"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            -- ["<cr>"] = "open_drop",
            -- ["t"] = "open_tab_drop",
            ["w"] = "noop", -- "open_with_window_picker",
            --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
            ["C"] = "close_node",
            -- ['C'] = 'close_all_subnodes',
            ["z"] = "close_all_subnodes",
            --["Z"] = "expand_all_nodes",
            ["a"] = {
              "add",
              -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
              -- some commands may take optional config options, see `:h neo-tree-mappings` for details
              config = {
                show_path = "absolute", -- "none", "relative", "absolute"
              },
            },
            ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
            ["d"] = "trash",
            ["r"] = {
              "rename",
              config = {
                show_path = "absolute" -- "none", "relative", "absolute"
              }
            },
            -- ["b"] = "rename_basename",
            ["y"] = "noop", -- "copy_to_clipboard",
            ["x"] = "noop", -- "cut_to_clipboard",
            ["p"] = "noop", -- "paste_from_clipboard",
            -- ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
            ["c"] = {
              "copy",
              config = {
                show_path = "absolute" -- "none", "relative", "absolute"
              }
            },
            ["m"] = {
              "move",
              config = {
                show_path = "absolute" -- "none", "relative", "absolute"
              }
            },
            -- ["q", "<C-c>"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<"] = "prev_source",
            [">"] = "next_source",
            -- ["i"] = {
            --   "show_file_details",
            --   -- format strings of the timestamps shown for date created and last modified (see `:h os.date()`)
            --   -- both options accept a string or a function that takes in the date in seconds and returns a string to display
            --   -- config = {
            --   --   created_format = "%Y-%m-%d %I:%M %p",
            --   --   modified_format = "relative", -- equivalent to the line below
            --   --   modified_format = function(seconds) return require('neo-tree.utils').relative_date(seconds) end
            --   -- }
            -- },
          },
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false, -- only works on Windows for hidden files/directories
            hide_by_name = {
              --"node_modules"
            },
            hide_by_pattern = { -- uses glob style patterns
              --"*.meta",
              --"*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
              --".gitignored",
            },
            always_show_by_pattern = { -- uses glob style patterns
              --".env*",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
              --".DS_Store",
              --"thumbs.db"
            },
            never_show_by_pattern = { -- uses glob style patterns
              --".null-ls_*",
            },
          },
          follow_current_file = {
            enabled = false,                      -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false,              -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = false,               -- when true, empty folders will be grouped together
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ["o"] = "open",
              ["<bs>"] = "noop",  -- "navigate_up",
              ["."] = "noop",     -- "set_root",
              ["H"] = "toggle_hidden",
              ["/"] = "noop",     -- "fuzzy_finder",
              ["D"] = "noop",     -- "fuzzy_finder_directory",
              ["#"] = "noop",     -- "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
              -- ["D"] = "fuzzy_sorter_directory",
              ["f"] = "noop",     -- "filter_on_submit",
              ["<c-x>"] = "noop", -- "clear_filter",
              ["[g"] = "noop",    -- "prev_git_modified",
              ["]g"] = "noop",    -- "next_git_modified",
              -- ["o"] = {
              --   "show_help",
              --   nowait = false,
              --   config = { title = "Order by", prefix_key = "o" },
              -- },
              ["oc"] = "noop", -- { "order_by_created", nowait = false },
              ["od"] = "noop", -- { "order_by_diagnostics", nowait = false },
              ["og"] = "noop", -- { "order_by_git_status", nowait = false },
              ["om"] = "noop", -- { "order_by_modified", nowait = false },
              ["on"] = "noop", -- { "order_by_name", nowait = false },
              ["os"] = "noop", -- { "order_by_size", nowait = false },
              ["ot"] = "noop", -- { "order_by_type", nowait = false },
              -- ['<key>'] = function(state) ... end,
            },
            fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
              -- ["<down>"] = "move_cursor_down",
              -- ["<C-n>"] = "move_cursor_down",
              -- ["<up>"] = "move_cursor_up",
              -- ["<C-p>"] = "move_cursor_up",
              -- ["<esc>"] = "close",
              -- ['<key>'] = function(state, scroll_padding) ... end,
            },
          },
          commands = {}, -- Add a custom command or override a global one using the same function name
        },
        buffers = {
          follow_current_file = {
            enabled = true,          -- This will find and focus the file in the active buffer every time
            --              -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = true,   -- when true, empty folders will be grouped together
          show_unloaded = true,
          window = {
            mappings = {
              -- ["d"] = "buffer_delete",
              -- ["bd"] = "buffer_delete",
              -- ["<bs>"] = "navigate_up",
              -- ["."] = "set_root",
              -- ["o"] = "noop"
              -- ["o"] = {
              --   "show_help",
              --   nowait = false,
              --   config = { title = "Order by", prefix_key = "o" },
              -- },
              -- ["oc"] = { "order_by_created", nowait = false },
              -- ["od"] = { "order_by_diagnostics", nowait = false },
              -- ["om"] = { "order_by_modified", nowait = false },
              -- ["on"] = { "order_by_name", nowait = false },
              -- ["os"] = { "order_by_size", nowait = false },
              -- ["ot"] = { "order_by_type", nowait = false },
            },
          },
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
              -- ["A"] = "git_add_all",
              -- ["gu"] = "git_unstage_file",
              -- ["ga"] = "git_add_file",
              -- ["gr"] = "git_revert_file",
              -- ["gc"] = "git_commit",
              -- ["gp"] = "git_push",
              -- ["gg"] = "git_commit_and_push",
              -- ["o"] = {
              --   "show_help",
              --   nowait = false,
              --   config = { title = "Order by", prefix_key = "o" },
              -- },
              -- ["oc"] = { "order_by_created", nowait = false },
              -- ["od"] = { "order_by_diagnostics", nowait = false },
              -- ["om"] = { "order_by_modified", nowait = false },
              -- ["on"] = { "order_by_name", nowait = false },
              -- ["os"] = { "order_by_size", nowait = false },
              -- ["ot"] = { "order_by_type", nowait = false },
            },
          },
        },
      })

      vim.keymap.set("n", "<C-e>", "<Cmd>Neotree left toggle<CR>", { silent = true })
      vim.keymap.set("n", "<C-w>f", function()
        if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "oil" or vim.bo.filetype == "git" then
          vim.cmd("Neotree left")
          return
        end

        if is_blank_screen_by_ls() and vim.fn.isdirectory(vim.fn.getcwd()) == 1 then
          vim.cmd("Neotree left")
          return
        end

        -- 前方一致で"fatal"の文字列があるかどうか判定
        dotgit = vim.fn.system("git rev-parse --show-toplevel")
        if string.sub(dotgit, 1, 5) == "fatal" then
          path = vim.fn.expand("%:p:h")
          vim.cmd("Neotree action=focus reveal_file=% dir=.")
          return
        end

        vim.defer_fn(function()
          vim.cmd("Neotree action=focus reveal_file=% dir=" .. dotgit)
        end, 170)
      end, { silent = true })
    end
  }
}
