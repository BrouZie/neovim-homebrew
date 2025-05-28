local config = require("nvim-treesitter.configs")
config.setup({
	ensure_installed = {"bash", "lua", "rst", "ninja", "python", "go", "vimdoc", "c"},
	highlight = { enable = true },
	indent = { enable = true },

})
