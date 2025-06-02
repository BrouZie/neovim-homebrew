local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- if the buffer is valid, reuse it; otherwise create a new scratch buffer
	local buf = vim.api.nvim_buf_is_valid(opts.buf) and opts.buf or vim.api.nvim_create_buf(false, true)

	-- window settings: centered, minimal, rounded border
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	-- open the floating window (it also sets focus into that window)
	local win = vim.api.nvim_open_win(buf, true, win_config)
	return { buf = buf, win = win }
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		-- 1) figure out the directory of the current buffer:
		local buf_dir = vim.fn.expand("%:p:h")

		-- 2) create (or reuse) the floating window:
		state.floating = create_floating_window({ buf = state.floating.buf })

		-- 3) now that win/buf is open & focused, start a terminal with cwd = buf_dir
		--
		-- Option A: use termopen(), which takes a 'cwd' option directly:
		vim.fn.termopen(vim.o.shell, { cwd = buf_dir })

	-- Option B (Neovim 0.8+): you can also do
	-- vim.cmd("terminal ++cwd=" .. vim.fn.shellescape(buf_dir))
	--
	-- Both will drop you into a shell whose working dir is the buffer's dir.
	else
		-- hide it when toggled off
		vim.api.nvim_win_hide(state.floating.win)
	end
end

-- map <Esc><Esc> in terminal-mode to go back to normal-mode
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- user‐command to toggle
vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})

vim.keymap.set({ "n", "t" }, "<space>tt", toggle_terminal)
