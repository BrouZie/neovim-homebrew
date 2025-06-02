local DEFAULT_PYTHON = "/usr/bin/python3" -- Viktig for python provider

-- ~/.config/nvim/lua/python_setup.lua

-- ─────────────────────────────────────────────────────────────────────────────
-- 0) Default interpreter when no venv is found
-- ─────────────────────────────────────────────────────────────────────────────
local DEFAULT_PYTHON = "/usr/bin/python3"

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Helper: search upward from a starting path for a venv directory
-- ─────────────────────────────────────────────────────────────────────────────
local function find_venv_dir(startpath)
	local uv = vim.loop
	local venv_names = { ".venv", "venv" }

	-- If startpath is a file, use its parent directory
	local stat = uv.fs_stat(startpath)
	local dir = startpath
	if stat and stat.type ~= "directory" then
		dir = vim.fn.fnamemodify(startpath, ":p:h")
	end

	-- Walk up until we hit the filesystem root
	while dir and #dir > 1 do
		for _, name in ipairs(venv_names) do
			local candidate = dir .. "/" .. name
			local s = uv.fs_stat(candidate)
			if s and s.type == "directory" then
				return candidate
			end
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end

	return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Helper: ensure pynvim is installed inside the given venv
-- ─────────────────────────────────────────────────────────────────────────────
local function ensure_pynvim_in_venv(venv_dir)
	-- Path to that venv’s python interpreter
	local python_bin = venv_dir .. "/bin/python"
	if vim.fn.executable(python_bin) ~= 1 then
		-- If for some reason python isn’t executable, bail out
		return
	end

	-- Check if “pynvim” is already installed: run “python -m pip show pynvim”
	local check_cmd = { python_bin, "-m", "pip", "show", "pynvim" }
	local handle = vim.fn.jobstart(check_cmd, { stdout_buffered = true, stderr_buffered = true })
	if handle <= 0 then
		return
	end

	-- Capture stdout/stderr
	local result = vim.fn.jobwait({ handle }, 5000)[1]
	-- jobwait returns exit code array; exit code 0 means “pynvim” was found
	if result ~= 0 then
		-- pynvim not found: install it via “python -m pip install --user pynvim”
		vim.notify("Installing pynvim into venv: " .. venv_dir, vim.log.levels.INFO)

		-- Use --quiet to reduce noise; you can remove --quiet if you want full logs
		local install_cmd = { python_bin, "-m", "pip", "install", "--quiet", "pynvim" }
		local h2 = vim.fn.jobstart(install_cmd, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_exit = function(_, code)
				if code == 0 then
					vim.schedule(function()
						vim.notify("✅ Installed pynvim in " .. venv_dir, vim.log.levels.INFO)
					end)
				else
					vim.schedule(function()
						vim.notify("❌ Failed to install pynvim in " .. venv_dir, vim.log.levels.ERROR)
					end)
				end
			end,
		})
		-- (We do not block; the callback will notify when done)
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Autocmd: on opening any Python buffer, either activate found venv (“.venv”/“venv”)
--    or fall back to DEFAULT_PYTHON if none exists. If venv is found, ensure pynvim.
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname == "" then
			return
		end

		local bufdir = vim.fn.fnamemodify(bufname, ":p:h")
		local venv_dir = find_venv_dir(bufdir)

		-- If no venv found, set python3_host_prog to DEFAULT_PYTHON and clear VIRTUAL_ENV
		if not venv_dir then
			if vim.g.python3_host_prog ~= DEFAULT_PYTHON then
				vim.g.python3_host_prog = DEFAULT_PYTHON
				vim.env.VIRTUAL_ENV = nil
				-- Remove any previously prepended “<oldvenv>/bin:” from PATH, if present
				local cur_PATH = vim.env.PATH or ""
				local escaped_bin = vim.pesc((vim.env.VIRTUAL_ENV or "") .. "/bin")
				vim.env.PATH = cur_PATH:gsub(escaped_bin .. ":", "")
				vim.notify("No venv found; using default Python.", vim.log.levels.INFO)
			end
			return
		end

		-- If we did find a venv, ensure pynvim inside it, then “activate” it:
		ensure_pynvim_in_venv(venv_dir)

		-- Now set python3_host_prog to <venv>/bin/python
		local python_bin = venv_dir .. "/bin/python"
		if vim.fn.executable(python_bin) == 1 then
			if vim.g.python3_host_prog ~= python_bin then
				vim.g.python3_host_prog = python_bin
				vim.notify("Activated venv: " .. venv_dir, vim.log.levels.INFO)
			end
		end

		-- Export VIRTUAL_ENV and prepend venv/bin to PATH so terminals use venv’s executables
		vim.env.VIRTUAL_ENV = venv_dir
		local bin_path = venv_dir .. "/bin"
		local cur_path = vim.env.PATH or ""
		if not cur_path:match(vim.pesc(bin_path)) then
			vim.env.PATH = bin_path .. ":" .. cur_path
		end
	end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Utility: open a floating terminal that runs the given command
-- ─────────────────────────────────────────────────────────────────────────────
local function float_run(cmd)
	-- 1) Create an unlisted scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- 2) Calculate float dimensions (80% of screen, centered)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- 3) Open a floating window for that buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	})

	-- 4) Start a terminal job inside that buffer
	vim.fn.termopen(cmd)

	-- 5) Immediately enter insert mode to see output
	vim.cmd("startinsert")

	-- 6) When the job exits, auto-close the float
	vim.api.nvim_buf_attach(buf, false, {
		on_detach = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, false)
			end
		end,
	})
end

-- ─────────────────────────────────────────────────────────────────────────────
-- 5) Keymap: <leader>rf → run the current Python file in a floating terminal
-- ─────────────────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>rf", function()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" or not vim.loop.fs_stat(filepath) then
		vim.notify("Buffer must be saved to disk before running", vim.log.levels.WARN)
		return
	end

	-- Use whatever python3_host_prog is currently set (venv or default)
	local py_prog = vim.g.python3_host_prog or DEFAULT_PYTHON
	float_run({ py_prog, filepath })
end, { desc = "Run current Python file in floating terminal" })
