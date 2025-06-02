local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

-- Create (or reuse) a centered floating window, returning { buf, win }
local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- If opts.buf is a valid buffer handle, reuse it; otherwise create a new scratch buf
	local buf
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- listed=false, scratch=true
	end

	local win_conf = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}
	local win = vim.api.nvim_open_win(buf, true, win_conf)
	return { buf = buf, win = win }
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		-- 1) Open (or reuse) the floating window & buffer
		state.floating = create_floating_window({ buf = state.floating.buf })

		-- 2) If this buffer isn't already a terminal, start one—but suppress any E5108 error
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			-- “silent! terminal” will not stop on E5108; it simply ignores it
			vim.cmd("silent! terminal")
		end
	else
		-- If the floating window exists, just hide it
		vim.api.nvim_win_hide(state.floating.win)
	end
end

-- Create :Floaterminal command
vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})

vim.keymap.set({ "n", "t" }, "<space>tt", toggle_terminal)
