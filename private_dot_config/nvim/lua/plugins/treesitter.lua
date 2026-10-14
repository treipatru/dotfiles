-- nvim-treesitter `main` only installs parsers; highlighting is started below with vim.treesitter.start().
-- Building parsers needs the tree-sitter CLI: `brew install tree-sitter-cli`
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- Rainbow brackets
  "https://github.com/HiPhish/rainbow-delimiters.nvim",
})

local ts = require("nvim-treesitter")

-- Parsers that are always installed (no-op when they already are). Others are installed on first use.
ts.install({
  "c",
  "bash",
  "css",
  "dockerfile",
  "git_rebase",
  "glsl",
  "graphql",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "php",
  "python",
  "query",
  "regex",
  "rust",
  "scss",
  "svelte",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
})

local max_filesize = 100 * 1024 -- 100 KB
local available -- parsers nvim-treesitter knows how to install, computed on first use

local function start(buf, lang)
  if vim.api.nvim_buf_is_valid(buf) then
    pcall(vim.treesitter.start, buf, lang)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end

    -- Disable highlighting for large files
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > max_filesize then
      return
    end

    if vim.treesitter.language.add(lang) then
      start(ev.buf, lang)
      return
    end

    -- Automatically install missing parsers when entering buffer
    available = available or ts.get_available()
    if vim.list_contains(available, lang) then
      ts.install(lang):await(function(err)
        if not err then
          vim.schedule(function()
            start(ev.buf, lang)
          end)
        end
      end)
    end
  end,
})

-- `.` selects the enclosing syntax node, repeat to expand (replaces nvim-treesitter-textsubjects)
vim.keymap.set({ "x", "o" }, ".", "an", { remap = true, desc = "Select parent node" })
