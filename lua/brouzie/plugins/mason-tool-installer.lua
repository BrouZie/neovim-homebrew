local config = require("mason-tool-installer")
config.setup({
	ensure_installed = {
		"debugpy",
		"mypy",
		"black",
		"pylint",
		"flake8",
		"isort",
		"lua_ls",
		"gopls",
		"pyright",
		"bashls",
	},
})

vim.lsp.enable("bashls")
vim.lsp.enable("gopls")
vim.lsp.enable("pyright")
vim.lsp.enable("lua_ls")

print("hello from BADPLACE")
