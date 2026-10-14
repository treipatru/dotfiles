vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("*") },
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim", -- built by the PackChanged hook in config/pack.lua
  "https://github.com/nvim-telescope/telescope-frecency.nvim", -- master: uses the v2 database (file_frecency_v2.bin)
})

--[[
-- Autocmds for Telescope
--]]
--
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd("TelescopeParent", "\t\t.*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end)
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "TelescopeResults",
  callback = function()
    vim.fn.clearmatches()
  end,
})

----------------------------------------------------------

-- Delete the selected mark in the `marks` picker
local function delete_mark(prompt_bufnr)
  local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  picker:delete_selection(function(selection)
    local mark = selection.value:sub(1, 1)
    if mark:match("[A-Z0-9]") then
      vim.api.nvim_del_mark(mark)
    else
      pcall(vim.api.nvim_buf_del_mark, picker.original_bufnr, mark)
    end
  end)
end

----------------------------------------------------------

local telescope = require("telescope")
local actions = require("telescope.actions")
local filename_first = require("custom.telescope").filename_first

telescope.setup({
  defaults = {
    path_display = {
      "shorten", -- shorten paths to max 4 chars
      shorten = 4,
    },
    -- Lua patterns matched anywhere in the path: anchor them to directories so that
    -- files like `buildFoo.ts` or `.github/` aren't hidden
    file_ignore_patterns = {
      "%.git/",
      "^build/",
      "/build/",
      "node_modules/",
    },
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-s>"] = "toggle_selection",
        ["<C-q>"] = "smart_send_to_qflist",
      },
    },
    prompt_prefix = "🔍 ",
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--hidden",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
  pickers = {
    buffers = {
      path_display = filename_first,
      sort_lastused = true,
      theme = "dropdown",
      previewer = false,
      mappings = {
        i = {
          ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
        },
      },
    },
    find_files = {
      path_display = filename_first,
      theme = "dropdown",
      previewer = false,
      layout_config = {
        width = 0.5,
      },
    },
    git_branches = {
      previewer = false,
      show_remote_tracking_branches = false,
    },
    git_files = {
      theme = "dropdown",
      path_display = filename_first,
      previewer = false,
    },
    grep_string = {
      theme = "ivy",
    },
    live_grep = {
      theme = "ivy",
    },
    lsp_references = {
      theme = "dropdown",
      path_display = filename_first,
      layout_config = {
        width = 0.8,
      },
    },
    marks = {
      attach_mappings = function(_, map)
        map("i", "<C-d>", delete_mark)
        return true -- Keep default mappings as well as the custom ones
      end,
    },
    oldfiles = {
      theme = "dropdown",
      previewer = false,
      path_display = filename_first,
    },
    current_buffer_fuzzy_find = {
      theme = "dropdown",
      layout_config = {
        width = 0.8,
      },
    },
  },
  extensions = {
    frecency = {
      show_filter_column = false, -- hide the workspace folder shown before each file
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
  },
})

telescope.load_extension("fzf")
telescope.load_extension("frecency")
telescope.load_extension("projects")
