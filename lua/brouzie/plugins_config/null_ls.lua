-- Not sure if i want to keep this
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls  = require('null-ls')

local opts = {
  sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.diagnostics.ruff,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- clear any existing formatting autocmds in this group for this buffer
      vim.api.nvim_clear_autocmds({
        group  = augroup,
        buffer = bufnr,
      })
      -- set up formatting on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        group    = augroup,
        buffer   = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
}

return opts
