-- Neovim half of herdr-nvim: code annotations sent to agents in the herdr workspace.
-- The herdr half (sidebar, file picker) is a herdr plugin: `herdr plugin install ChmaraX/herdr-nvim`.
vim.pack.add({ "https://github.com/ChmaraX/herdr-nvim" })

local herdr = require("herdr-nvim")

-- Default keymaps under <leader>a: c comment, l list, s paste to agent, S send, i reference
herdr.setup()

-- The sidebar's nvim (a herdr-nvim daemon) calls setup() again on VimEnter, for configs that
-- don't install the plugin. Ours already did, so make that a no-op instead of a warning per keymap.
herdr.setup = function() end
