lvim.lsp.installer.setup.automatic_installation = true

local null_ls = require("null-ls")

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "gopls" })

local lsp_manager = require "lvim.lsp.manager"

lsp_manager.setup("gopls", {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
  on_init = require("lvim.lsp").common_on_init,
  capabilities = require("lvim.lsp").common_capabilities(),
  settings = {
    gopls = {
      usePlaceholders = true,
      gofumpt = true,
      codelenses = {
        generate = false,
        gc_details = true,
        test = true,
        tidy = true,
      },
    },
  },
})

local status_ok, gopher = pcall(require, "gopher")
if not status_ok then
  return
end

gopher.setup {
  commands = {
    go = "go",
    gomodifytags = "gomodifytags",
    gotests = "gotests",
    impl = "impl",
    iferr = "iferr",
  },
}

------------------------
-- Language Key Mappings
------------------------

------------------------
-- Dap
------------------------
local dap_ok, dapgo = pcall(require, "dap-go")
if not dap_ok then
  return
end


local code_actions = require("lvim.lsp.null-ls.code_actions")
code_actions.setup({
	-- null_ls.builtins.code_actions.eslint,
	null_ls.builtins.code_actions.eslint_d,

	null_ls.builtins.code_actions.shellcheck,
})

-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	null_ls.builtins.formatting.prettier,
	null_ls.builtins.formatting.stylua,
	null_ls.builtins.formatting.goimports,

	null_ls.builtins.formatting.shfmt,

	null_ls.builtins.formatting.pg_format,

	-- solidity
	null_ls.builtins.formatting.prettier.with({
		filetypes = { "solidity" },
	}),
})

-- set additional linters
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
	-- null_ls.builtins.diagnostics.eslint,
	null_ls.builtins.diagnostics.eslint_d,
	null_ls.builtins.diagnostics.golangci_lint,
	null_ls.builtins.diagnostics.staticcheck,

	null_ls.builtins.diagnostics.shellcheck,

	null_ls.builtins.diagnostics.zsh,

	-- null_ls.builtins.diagnostics.actionlint, -- GitHub Actions
})
