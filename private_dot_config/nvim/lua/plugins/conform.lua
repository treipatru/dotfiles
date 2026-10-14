vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
  -- Define your formatters
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  },
  -- Set default options
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- Set up format-on-save
  format_on_save = { timeout_ms = 500 },
  -- Customize formatters
  formatters = {
    shfmt = {
      prepend_args = { "-i", "2" },
    },
  },
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set("", "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })
