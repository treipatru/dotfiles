vim.pack.add({
  -- Provides the server configs (lsp/*.lua) used by vim.lsp.enable()
  "https://github.com/neovim/nvim-lspconfig",
  { src = "https://github.com/mason-org/mason.nvim", version = vim.version.range("2") },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim", version = vim.version.range("2") },
  "https://github.com/dmmulroy/ts-error-translator.nvim",
})

-- Language servers to enable
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local servers = {
  "astro",
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "eslint",
  "graphql",
  "html",
  "jsonls",
  "lua_ls",
  "tailwindcss",
  "ts_ls",
  "yamlls",
}

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = vim.list_extend({ "ast_grep" }, servers),
  automatic_enable = false, -- enabled explicitly below
})

-- Make lua_ls aware of the Neovim runtime when editing this config.
-- Projects with their own .luarc.json are left alone.
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = { Lua = {} },
})

-- nvim-lspconfig only attaches graphql to .tsx/.jsx; also cover plain .ts/.js files with embedded queries
-- and only start it in projects with a GraphQL config (nvim-lspconfig's starts it without a root otherwise)
vim.lsp.config("graphql", {
  filetypes = { "graphql", "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, function(name)
      return name:match("^%.?graphql%.config%.") ~= nil or name:match("^%.graphqlrc") ~= nil
    end)
    if root then
      on_dir(root)
    end
  end,
})

-- TypeScript: projects on TypeScript 7 (native) get its own language server (`tsc --lsp`), so the
-- editor matches what they type-check with. Everything else keeps ts_ls (TypeScript <= 6).
local native_tsc = {} -- project root -> whether node_modules/.bin/tsc is TypeScript >= 7

local function uses_native_tsc(root)
  if native_tsc[root] == nil then
    local bin = vim.fs.joinpath(root, "node_modules/.bin/tsc")
    local out = vim.fn.executable(bin) == 1 and vim.system({ bin, "--version" }, { text = true }):wait()
    local version = out and out.code == 0 and vim.version.parse(out.stdout or "")
    native_tsc[root] = version and version.major >= 7 or false
  end
  return native_tsc[root]
end

local lockfiles = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
local ts_ls_root_dir = vim.lsp.config.ts_ls.root_dir

-- Replaces nvim-lspconfig's root_dir and cmd: its version warns in every project without
-- TypeScript 7, and falls back to a global `tsc` when the config is overridden
vim.lsp.config("tsc", {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start(
      { vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsc"), "--lsp", "--stdio" },
      dispatchers
    )
  end,
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { lockfiles, { ".git" } })
    if root and uses_native_tsc(root) then
      on_dir(root)
    end
  end,
})

vim.lsp.config("ts_ls", {
  root_dir = function(bufnr, on_dir)
    ts_ls_root_dir(bufnr, function(root)
      if not uses_native_tsc(root) then
        on_dir(root)
      end
    end)
  end,
})

vim.lsp.enable(servers)
vim.lsp.enable("tsc") -- comes from the project's node_modules, not mason

require("ts-error-translator").setup({ servers = { "astro", "ts_ls" } })

-- tsc (TypeScript 7) sends diagnostics on request ("pull") instead of pushing them, which
-- ts-error-translator doesn't hook. Translate those the same way the plugin does.
local on_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]
vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, ...)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if result and result.items and client and client.name == "tsc" then
    local parser = require("ts-error-translator.parser")
    for _, diag in ipairs(result.items) do
      local parsed = diag.code and parser.parse_errors(("TS%s: %s"):format(diag.code, diag.message)) or {}
      if parsed[1] and parsed[1].improvedError then
        diag.message = parsed[1].improvedError.body
      end
    end
  end
  return on_diagnostic(err, result, ctx, ...)
end
