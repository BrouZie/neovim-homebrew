require("brouzie.utils")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.python3_host_prog = "/usr/bin/python3" -- Viktig for python provider

vim.o.number = true
vim.o.relativenumber = true
-- How many lines i want as minimum distance to end of screen (up and down)
vim.o.scrolloff = 5
vim.sidescrolloff = 10
vim.o.mouse = "a"
vim.opt.background = "dark"

vim.opt.clipboard:append("unnamedplus")

-- Highlighting when yayænkin
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Here comes a section i want to have moved to separate file later on see https://github.com/Sin-cy/dotfiles/blob/main/nvim/.config/nvim/lua/sethy/core/keymaps.lua
local opts = { noremap = true, silent = true }
-- Remember what was yææænked
vim.keymap.set("v", "p", '"_dp', opts) -- Doesn't work?
-- Copies or Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], opts)
-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
	vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
	print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy file path to clipboard" })
-- CWD into working dir and prompt me please
vim.keymap.set("n", "<leader>cd", "<cmd>cd %:p:h|pwd<CR>", { desc = "Change CWD to current file’s directory",
})
-- vim.keymap.set("n", "<leader>pe", vim.cmd.Ex, { desc = 'Moving to "explorer"' })
-- Using <Esc> when searching for patterns (/pattern), i will go back to 'n' and unhighlight everything
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Automatic unhighlight" })

-- Really nice keymaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- Lets me intent multiple times (without having to press v every time)
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Paste without replacing clipboard
vim.keymap.set("x", "<leader>P", [["_dP"]])
vim.keymap.set("v", "x", "'_x", opts) -- funker ikke??

-- Replace the word cursor is on globally
vim.keymap.set(
	"n",
	"<leader>r",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word cursor is on globally" }
)

vim.keymap.set("n", "<leader>x", "<cmd>!python3 %<CR>", { silent = true, desc = "makes file executable" })

-- Split panes vert and hori
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>s", ":split<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Move between panes
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- Toggle LSP diagnostics visibility
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
	isLspDiagnosticsVisible = not isLspDiagnosticsVisible
	vim.diagnostic.config({
		virtual_text = isLspDiagnosticsVisible,
		underline = isLspDiagnosticsVisible,
	})
end, { desc = "Toggle LSP diagnostics" })

------------------------------------------------
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.cursorline = false

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
-- Decrease mapped sequence wait time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.tabstop = 4
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Handles error where you try to :q without having :w beforehand
vim.o.confirm = true
vim.opt.shiftwidth = 4
vim.g.editorconfig = true

require("brouzie.lazy")
require("current-theme")
require("brouzie.terminalpop")
print("Welcome")
