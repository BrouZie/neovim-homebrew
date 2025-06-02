vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.python3_host_prog = "/usr/bin/python3" -- Viktig for python provider
--require("brouzie.python_setup")

vim.o.number = true
vim.o.relativenumber = true
-- How many lines i want as minimum distance to end of screen (up and down)
vim.o.scrolloff = 10
vim.sidescrolloff = 10
vim.o.mouse = "a"

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Highlighting when yayænkin
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.cursorline = true

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

-- This one takes you into normalmode if you are in terminal (:terminal)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex, { desc = 'Moving to "explorer"' })
-- Using <Esc> when searching for patterns (/pattern), i will go back to 'n' and unhighlight everything
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Automatic unhighlight" })

require("brouzie.lazy")
require("brouzie.plugins")
print("Welcome")
