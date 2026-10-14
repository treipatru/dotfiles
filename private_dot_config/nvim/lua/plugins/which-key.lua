vim.pack.add({ "https://github.com/folke/which-key.nvim" })

local wk = require("which-key")

wk.setup({
  plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = false, -- shows your registers on " in
  },
})

-- Group labels. The mappings are in config/keymaps.lua, except <leader>a (herdr-nvim).
wk.add({
  { "<leader>a", group = "Agent", mode = { "n", "x" } },
  { "<leader>b", group = "Buffers" },
  { "<leader>c", group = "Code" },
  { "<leader>e", group = "Editor" },
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>w", group = "Window" },
})
