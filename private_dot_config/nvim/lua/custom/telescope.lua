local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local M = {}

-- Display `filename<tab><tab>short/parent/dir` (the parent is dimmed by an autocmd in plugins/telescope.lua)
function M.filename_first(_, path)
  local cwd = vim.uv.cwd()
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)

  -- Remove cwd from the start of parent, if present
  if vim.startswith(parent, cwd) then
    parent = parent:sub(#cwd + 2) -- Remove cwd and the trailing "/"
  end

  -- Cut each subfolder to a max length of 5 characters, except the last one
  if parent ~= "." and parent ~= "" then
    local subfolders = {}
    for folder in parent:gmatch("[^/]+") do
      table.insert(subfolders, folder)
    end
    for i = 1, #subfolders - 1 do
      subfolders[i] = subfolders[i]:sub(1, 5)
    end
    parent = table.concat(subfolders, "/")
  end

  if parent == "." or parent == "" then
    return tail
  end
  return string.format("%s\t\t%s", tail, parent)
end

function M.grep_prompt()
  require("telescope.builtin").grep_string({
    workspace = "CWD",
    previewer = true,
    prompt_prefix = "🔍 ",
    prompt_title = "Grep in occurences",
    path_display = { "shorten", shorten = 4 },
    search = vim.fn.input("Rg "),
  })
end

--------------------------------------------------------------------------------

M.frecency = function()
  local root = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), "\n", "")

  if vim.v.shell_error == 0 then
    require("telescope").extensions.frecency.frecency({
      cwd = root,
      path_display = M.filename_first,
      workspace = "CWD",
      previewer = false,
      prompt_title = "Frecent files",
      layout_config = {
        width = 0.5,
      },
    })
  else
    require("telescope").extensions.frecency.frecency({
      workspace = "CWD",
      path_display = M.filename_first,
      previewer = false,
      prompt_title = "Frecent files",
      layout_config = {
        width = 0.5,
      },
    })
  end
end

--------------------------------------------------------------------------------
local is_inside_work_tree = {}

M.project_files = function()
  local opts = {} -- define here if you want to define something

  local cwd = vim.fn.getcwd()
  if is_inside_work_tree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    is_inside_work_tree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_work_tree[cwd] then
    require("telescope.builtin").git_files(opts)
  else
    require("telescope.builtin").find_files(opts)
  end
end

--------------------------------------------------------------------------------

M.live_grep_from_project_git_root = function()
  local function is_git_repo()
    vim.fn.system("git rev-parse --is-inside-work-tree")

    return vim.v.shell_error == 0
  end

  local function get_git_root()
    local dot_git_path = vim.fn.finddir(".git", ".;")
    return vim.fn.fnamemodify(dot_git_path, ":h")
  end

  local opts = {}

  if is_git_repo() then
    opts = {
      cwd = get_git_root(),
    }
  end

  require("telescope.builtin").live_grep(opts)
end

--------------------------------------------------------------------------------

M.editor_config_files = function()
  require("telescope.builtin").find_files({
    prompt_title = "Config Files",
    cwd = vim.fn.stdpath("config"),
  })
end

--------------------------------------------------------------------------------
M.live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, " ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      return vim.list_extend(
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
      )
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Multigrep",
      finder = finder,
      preview = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

return M
