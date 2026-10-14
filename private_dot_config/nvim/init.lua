-- Cache compiled Lua modules for faster startup (lazy.nvim used to do this)
vim.loader.enable()

vim.g.mapleader = " " -- asign leader key

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.pack")

-- Each module installs its plugins with vim.pack.add() and configures them.
-- There is no dependency resolution, so order matters where noted.
for _, name in ipairs({
  "visual", -- colorscheme and icons first, other UI plugins build on them
  "treesitter",
  "lsp",
  "blink",
  "conform",
  "editor", -- before telescope: provides the `projects` extension
  "telescope",
  "gitsigns",
  "which-key",
  "autopairs",
  "hop",
  "qf",
  "text-objects",
  "herdr",
}) do
  local ok, err = pcall(require, "plugins." .. name)
  if not ok then
    vim.notify(("Error loading plugins.%s:\n%s"):format(name, err), vim.log.levels.ERROR)
  end
end
