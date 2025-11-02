-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local utils = require "lspconfig/util"

local servers = {
    "html",
    "cssls",
    "ts_ls",
    "tailwindcss",
    "gleam",
    "prismals",
    "emmet_language_server",
    "svelte",
    "eslint",
}

local config = {
    ts_ls = {
        cmd = { "vtsls", "--stdio" },
    },
    tailwindcss = {
        init_options = {
            userLanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
            },
        },
        settings = {
            tailwindCSS = {
                emmetCompletions = true,
                experimental = {
                    classRegex = {
                        'class[:]\\s*"([^"]*)"',
                        { "cva\\(([^)]*)\\)",  "[\"'`]([^\"'`]*).*?[\"'`]" },
                        { "cn\\(([^)]*)\\)",   "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                        { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                        "(?:headClassName|headContainerClassName|cellClassName):\\s*?[\"'`]([^\"'`]*).*?[\"'`]",
                        { "(?:classNames)=\\s*(?:\"|'|{`|{{)([^)]*)([^(?:\"|'|`}||}})]*)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    },
                },
            },
        },
    },
    emmet_language_server = {
        filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "pug",
            "typescriptreact",
            "heex",
            "elixir",
        },
    },
    eslint = {
        root_dir = utils.root_pattern "package.json",
    },
}

-- lsps with default config
for _, lsp in ipairs(servers) do
    local cfg = config[lsp] or {}
    cfg.on_attach = on_attach
    cfg.on_init = on_init
    cfg.capabilities = capabilities
    vim.lsp.config(lsp, cfg)
end

-- typescript
-- lspconfig.tsserver.setup {
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
-- }
