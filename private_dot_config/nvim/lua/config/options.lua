-- Options are loaded before any plugin, so plugins see the final values.
-- See `:h option-list` for everything available.

local g = vim.g
local o = vim.o
local opt = vim.opt

-- Globals read by (Vimscript) plugins
g.netrw_special_syntax = true
g.rooter_patterns = { ".git", "Makefile" } -- vim-rooter

o.clipboard = "unnamedplus" -- copy/paste to system clipboard
o.completeopt = "menu,menuone,noselect" -- completion
o.cursorline = true
o.expandtab = true -- use spaces instead of tabs
opt.fillchars = { fold = " " }
o.foldenable = false
o.foldlevel = 99
o.foldmethod = "indent"
o.hidden = true -- enable background buffers
o.history = 100 -- remember n lines in history
o.hlsearch = true
o.ignorecase = true
o.incsearch = true
o.laststatus = 3 -- use single status line for all windows
o.mouse = "a"
o.number = true
o.relativenumber = true
o.scrolloff = 15
o.shiftwidth = 4 -- shift 4 spaces when tabbing
o.showmatch = true
o.sidescrolloff = 8 -- columns of context
o.smartindent = true -- autoindent new lines
o.splitbelow = true -- prefer splitting below in horizontal
o.splitright = true -- prefer splitting right in vertical
o.swapfile = false -- don't create vim swap files
o.tabstop = 4 -- 1 tab = 4 spaces
o.termguicolors = true -- enable 24-bit RGB colors
o.timeoutlen = 500 -- leader key timeout
o.undofile = true -- store undo history in files
o.updatetime = 50
o.wildmenu = false
o.wrap = false -- disable line wrap
opt.viewoptions:remove("curdir")
