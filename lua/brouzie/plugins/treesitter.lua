local config = require("nvim-treesitter.configs")
config.setup({
	ensure_installed = {"bash", "lua", 'diff', 'html', 'luadoc', 'query', 'markdown', 'markdown_inline' , "python", "go", "vimdoc", "c"},
	highlight = { enable = true },
	indent = { enable = true },

})
