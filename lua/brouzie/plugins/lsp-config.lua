local config = require('mason-tool-installer')
config.setup({
	ensure_installed = { 'debugpy', 'mypy', 'black', 'pylint', 'flake8', 'isort', 'lua_ls', 'gopls', 'pyright', 'bashls' }

})

vim.lsp.enable( 'bashls' )
vim.lsp.enable( 'gopls' )
vim.lsp.enable( 'pyright' )
vim.lsp.enable( 'lua_ls' )

-- Added from :help lspconfig-all
vim.lsp.config('lua_ls', {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath('config')
				and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using (most
				-- likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				-- Tell the language server how to find Lua modules same way as Neovim
				-- (see `:h lua-module-load`)
				path = {
					'lua/?.lua',
					'lua/?/init.lua',
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME
					-- Depending on the usage, you might want to add additional paths
					-- here.
					-- '${3rd}/luv/library'
					-- '${3rd}/busted/library'
				}
				-- Or pull in all of 'runtimepath'.
				-- NOTE: this is a lot slower and will cause issues when working on
				-- your own configuration.
				-- See https://github.com/neovim/nvim-lspconfig/issues/3189
				-- library = {
				--   vim.api.nvim_get_runtime_file('', true),
				-- }
			}
		})
	end,
	settings = {
		Lua = {}
	}
})

vim.lsp.config('pyright', {
	  settings = {
    python = {
      analysis = {
        -- Let Pyright inspect all files in your workspace, not just buffers you currently have open
        diagnosticMode        = "workspace",
        -- Auto‐add any paths found in sys.path (venv, installed packages, etc.)
        autoSearchPaths       = true,
        -- If you import modules from your project root, add "." to extraPaths
        extraPaths            = { "." },
        -- Make Pyright use type stubs from installed libraries, if available
        useLibraryCodeForTypes = true,
      },
    },
  },

  -- Make sure the LSP root is detected properly (often Neovim’s default is fine,
  -- but you can customize root_dir if you have nested and/or monorepo layouts):
  -- root_dir = require("lspconfig.util").root_pattern("pyproject.toml", "setup.py", ".git"),
})
