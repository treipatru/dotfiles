vim.pack.add({ "https://github.com/windwp/nvim-autopairs" })

require("nvim-autopairs").setup({
  map_bs = false,
  map_cr = false,
  enable_check_bracket_line = true,
})
