local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { { "prettier" } },
    typescript = { { "prettier" } },
    javascriptreact = { { "prettier" } },
    typescriptreact = { { "prettier" } },
    svelte = { { "prettier" } },
    css = { { "prettier" } },
    html = { { "prettier" } },
    json = { { "prettier" } },
    ["_"] = { "trim_whitespace" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
