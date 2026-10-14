vim.pack.add({
  -- Release tags download a prebuilt fuzzy matcher; `main` is the unreleased v2
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

-- LSP capabilities are registered by the plugin itself (vim.lsp.config("*", ...))
require("blink.cmp").setup({
  -- <CR> accept, <C-Space> open, <C-e> cancel, <C-n>/<C-p> select, <C-b>/<C-f> scroll docs
  keymap = { preset = "enter" },
  completion = {
    menu = { border = "rounded" },
    documentation = { auto_show = true, window = { border = "rounded" } },
  },
  cmdline = {
    -- Show the menu while typing `:` commands and `/` searches
    completion = { menu = { auto_show = true } },
  },
})
