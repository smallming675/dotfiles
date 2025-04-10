local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    rust = { "rustfmt" },
    javascript = { "prettierd" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
