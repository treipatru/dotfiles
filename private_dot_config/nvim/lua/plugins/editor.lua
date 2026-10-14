vim.pack.add({
  -- Floating terminal
  "https://github.com/voldikss/vim-floaterm",
  -- Git fugitive
  "https://github.com/tpope/vim-fugitive",
  -- Easy maximize split
  "https://github.com/szw/vim-maximizer",
  -- Easy split/join statements
  "https://github.com/AndrewRadev/splitjoin.vim",
  -- Easy surround (default keymaps, no setup needed)
  "https://github.com/kylechui/nvim-surround",
  -- Auto change pwd
  "https://github.com/airblade/vim-rooter",
  -- Project management
  "https://github.com/ahmedkhalf/project.nvim",
})

-- git-like undo tree, built in since Nvim 0.12 (`:Undotree`)
vim.cmd.packadd("nvim.undotree")

require("project_nvim").setup({
  patterns = { ".git", "Makefile" },
  manual_mode = true,
  -- LSP detection uses vim.lsp.buf_get_clients(), deprecated in Nvim 0.12. The plugin is unmaintained.
  detection_methods = { "pattern" },
})
