vim.pack.add({ { src = "https://github.com/nvim-mini/mini.ai", version = "stable" } })

require("mini.ai").setup({
  custom_textobjects = {
    -- `ib`/`ab`: any bracket, including <> (was vim-textobj-anyblock). `iq`/`aq` (any quote) is a default.
    b = { { "%b()", "%b[]", "%b{}", "%b<>" }, "^.().*().$" },
  },
  -- The default `an`/`in` would override Neovim's built-in node selection, which `.` relies on
  mappings = {
    around_next = "aN",
    inside_next = "iN",
    around_last = "aL",
    inside_last = "iL",
  },
})
