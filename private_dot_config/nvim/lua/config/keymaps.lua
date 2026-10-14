-- All keymaps live here. which-key reads each `desc`; group labels are in plugins/which-key.lua.
-- Plugin commands are resolved when the key is pressed, so plugins don't need to be loaded yet.

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
end

-----------------------------------------------------------------------------------------
-- Navigation and other improvements

-- Move around splits with ctrl+hjkl. At the edge of Neovim, keep going into the neighbouring
-- herdr pane (herdr passes these keys through to Neovim, see ~/.config/herdr/scripts/navigate.sh).
local function navigate(direction)
  local wincmd = ({ left = "h", down = "j", up = "k", right = "l" })[direction]
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(wincmd)
    if vim.api.nvim_get_current_win() ~= win or not vim.env.HERDR_TAB_ID then
      return
    end

    -- Move from herdr's focused pane (this one). Not HERDR_PANE_ID: the sidebar's nvim is a
    -- daemon started from another pane.
    local herdr = vim.env.HERDR_BIN_PATH or "herdr"
    vim.system({ herdr, "pane", "list" }, { text = true }, function(out)
      local ok, data = pcall(vim.json.decode, out.stdout or "")
      for _, pane in ipairs(ok and vim.tbl_get(data, "result", "panes") or {}) do
        if pane.focused then
          vim.system({ herdr, "pane", "focus", "--pane", pane.pane_id, "--direction", direction })
          return
        end
      end
    end)
  end
end

map("n", "<C-h>", navigate("left"))
map("n", "<C-j>", navigate("down"))
map("n", "<C-k>", navigate("up"))
map("n", "<C-l>", navigate("right"))

-- Uppercase y yanks from cursor to last non-blank character of line
map("n", "Y", "yg_")

-- Easier jump to start/end of line
map("n", "H", "^")
map("n", "L", "$")

-- Keep things centered when jumping to next
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Keep cursor in place when joining lines
map("n", "J", "mzJ`z")

-- o/O adds empty line without insert mode
map("n", "o", "o<Esc>")
map("n", "O", "O<Esc>")

-- Exit insert mode
map("i", "jj", "<Esc>")

-- `cw` changes inside word
map("x", "w", "iw")
map("o", "w", "iw")

-- Fuzzy search in current buffer
map("n", "?", "<cmd>Telescope current_buffer_fuzzy_find<CR>")

-- Live grep with selected text as default selection
map("v", "<leader>fg", "y<ESC>:Telescope live_grep default_text=<c-r>0<CR>")

map("v", "s", ":'<,'>sort<CR>")

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-----------------------------------------------------------------------------------------
-- Leader mappings

map("n", "<leader>*", function()
  require("custom.telescope").grep_prompt()
end, { desc = "Grep word" })
map("n", "<leader>o", "<cmd>Telescope oldfiles<CR>", { desc = "Old files" })
-- Open nnn in the current file's folder with the file selected (floaterm closes it when nnn exits)
map("n", "<leader>.", function()
  local cmd = "FloatermNew --name=nnn --opener=edit --height=0.8 --width=0.4 nnn"
  local file = vim.fn.expand("%:p")
  if vim.fn.filereadable(file) == 1 then
    cmd = cmd .. " " .. vim.fn.shellescape(file)
  end
  vim.cmd(cmd)
  -- nnn quits on a quick double Esc, so one Esc press is enough
  map("t", "<Esc>", "<Esc><Esc>", { buffer = true })
end, { desc = "File browser" })
map("n", "<leader>,", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>/", function()
  require("custom.telescope").live_grep_from_project_git_root()
end, { desc = "Grep" })
map("n", "<leader><Space>", function()
  require("custom.telescope").frecency()
end, { desc = "Find files" })
map("n", "<leader>q", "<cmd>QFToggle!<CR>", { desc = "QuickFix list" })
map("n", "<leader>s", "<cmd>w<CR>", { desc = "Save buffer" })
map("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undotree" })
map("n", "<leader>j", "<cmd>HopWord<CR>", { desc = "Jump" })
map("n", "<leader>t", "<cmd>Telescope resume<CR>", { desc = "Telescope resume" })

-- Buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete" })
map("n", "<leader>bo", "<cmd>execute '%bdelete|edit #|normal `\"'|bdelete#<CR>", { desc = "Delete all" })

-- Code
map("n", "<leader>ci", function()
  require("custom.navigation").definition()
end, { desc = "Implementation" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnosic" })
map("n", "<leader>co", function()
  require("custom.navigation").references()
end, { desc = "Occurences of symbol" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Editor
map("n", "<leader>ef", function()
  require("custom.telescope").editor_config_files()
end, { desc = "Files" })
map("n", "<leader>eh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- Find
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fc", "<cmd>Telescope command_history<CR>", { desc = "Command history" })
map("n", "<leader>ff", function()
  require("custom.telescope").project_files()
end, { desc = "Files" })
map("n", "<leader>fp", "<cmd>Telescope projects<CR>", { desc = "Projects" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fs", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Symbols" })

-- Git
map("n", "<leader>gb", "<cmd>G blame<CR>", { desc = "Blame line" })
map("n", "<leader>gs", "<cmd>Telescope git_branches<CR>", { desc = "Switch branch" })
map("n", "<leader>gg", "<cmd>0G<CR>", { desc = "Fugitive Status" })
map("n", "<leader>gh", "<cmd>Telescope git_bcommits theme=dropdown<CR>", { desc = "File history" })
map("n", "<leader>gl", "<cmd>GcLog<CR>", { desc = "Log" })

-- Window
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete split" })
map("n", "<leader>wh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wm", "<cmd>MaximizerToggle<CR>", { desc = "Maximize split" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "Delete all" })
map("n", "<leader>wv", "<cmd>vsp<CR>", { desc = "Vertical split" })

-- Previous / next
map("n", "[c", '<cmd>lua require("gitsigns").nav_hunk("prev")<CR>zzzv', { desc = "Hunk" })
map("n", "]c", '<cmd>lua require("gitsigns").nav_hunk("next")<CR>zzzv', { desc = "Hunk" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Diagnostic" })
map("n", "[q", "<cmd>QPrev<CR>zzzv", { desc = "QuickFix list item" })
map("n", "]q", "<cmd>QNext<CR>zzzv", { desc = "QuickFix list item" })
