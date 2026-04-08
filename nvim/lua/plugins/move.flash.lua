return {
  "folke/flash.nvim",
  keys = {
    {
      ";",
      function() require("flash").jump() end,
      mode = "n",
    },
  },
  opts = {
    labels = "hjklasdfgyuiopqwertnmzxcvb",
    label = {
      uppercase = false,
    },
    modes = {
      search = { enabled = false },
      char = { enabled = false },
    },
  },
}
