-- LSP navigation with GraphQL fallbacks.
--
-- The GraphQL language server has no "references" support, can't resolve root fields when
-- `type Query` / `type Mutation` are split across files, and ignores `/* gql */` strings.
-- So inside GraphQL (.graphql files, or queries embedded in JS/TS, see after/queries/ecma/injections.scm)
-- we fall back to searching the project text.

local M = {}

-- graphql-config files: graphql.config.yml, .graphqlrc, .graphqlrc.json, ...
local function is_graphql_config(name)
  return name:match("^%.?graphql%.config%.") ~= nil or name:match("^%.graphqlrc") ~= nil
end

local function graphql_root(bufnr)
  return vim.fs.root(bufnr, is_graphql_config) or vim.fs.root(bufnr, ".git") or vim.uv.cwd()
end

-- Whether the cursor is in GraphQL code, including queries embedded in JS/TS strings
local function in_graphql(bufnr)
  if vim.bo[bufnr].filetype == "graphql" then
    return true
  end
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return false
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  parser:parse({ row - 1, row })
  return parser:language_for_range({ row - 1, col, row - 1, col }):lang() == "graphql"
end

-- Jump straight to a single result, otherwise pick from a list
local function show(items, title)
  if #items == 1 then
    local item = items[1]
    vim.cmd("normal! m'")
    vim.cmd.edit(vim.fn.fnameescape(item.filename))
    vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
    vim.cmd("normal! zzzv")
  else
    vim.fn.setloclist(0, {}, " ", { title = title, items = items })
    require("telescope.builtin").loclist()
  end
end

-- Type (`type Foo`, `input Foo`, `enum Foo`, ...) and field (`  foo(` / `  foo:`) definitions named `name`
local function search_schema(name, root)
  local pattern = ([=[^\s*(extend\s+)?(type|input|enum|interface|union|scalar)\s+%s\b|^\s+%s\s*[(:]]=]):format(
    name,
    name
  )
  local out = vim
    .system({ "rg", "--vimgrep", "--glob", "*.{graphql,gql}", "--regexp", pattern, root }, { text = true })
    :wait()

  local items = {}
  for _, line in ipairs(vim.split(out.stdout or "", "\n", { trimempty = true })) do
    local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
    if file then
      table.insert(items, { filename = file, lnum = tonumber(lnum), col = tonumber(col), text = vim.trim(text) })
    end
  end
  return items
end

local function schema_fallback(bufnr, name)
  local items = in_graphql(bufnr) and name:match("^[_%a][_%w]*$") and search_schema(name, graphql_root(bufnr)) or {}
  if #items > 0 then
    show(items, "GraphQL schema: " .. name)
  else
    vim.notify("No definition found for " .. name, vim.log.levels.WARN)
  end
end

-- Go to definition. Inside GraphQL, falls back to the schema files when no server has an answer.
function M.definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.fn.expand("<cword>")
  local method = "textDocument/definition"

  -- buf_request_all() never calls back when no attached server supports the method
  if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
    return schema_fallback(bufnr, name)
  end

  vim.lsp.buf_request_all(bufnr, method, function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, function(results)
    local items = {}
    for client_id, res in pairs(results) do
      local locations = res.result
      if locations and not vim.tbl_isempty(locations) then
        if locations.uri or locations.targetUri then
          locations = { locations }
        end
        local client = vim.lsp.get_client_by_id(client_id)
        vim.list_extend(items, vim.lsp.util.locations_to_items(locations, client and client.offset_encoding))
      end
    end

    if #items > 0 then
      show(items, "LSP definitions")
    else
      schema_fallback(bufnr, name)
    end
  end)
end

-- Find occurrences. Inside GraphQL, a whole-word search across schema, resolvers and queries;
-- elsewhere, LSP references.
function M.references()
  local bufnr = vim.api.nvim_get_current_buf()
  if not in_graphql(bufnr) then
    return require("telescope.builtin").lsp_references()
  end

  local name = vim.fn.expand("<cword>")
  require("telescope.builtin").grep_string({
    cwd = graphql_root(bufnr),
    search = name,
    word_match = "-w",
    prompt_title = "GraphQL occurrences: " .. name,
    additional_args = { "--glob", "*.{graphql,gql,ts,tsx,js,jsx}" },
  })
end

return M
