return {
	"nvim-treesitter/nvim-treesitter", 
	build = "TSUpdate",
	config = function()
		require 'nvim-treesitter.configs'.setup {
			ensure_installed = {"bash", "lua", 'diff', 'html', 'luadoc', 'query', 'markdown', 'markdown_inline' , "python", "go", "vimdoc", "c"},
			highlight = { enable = true },
	}
	end,
}
