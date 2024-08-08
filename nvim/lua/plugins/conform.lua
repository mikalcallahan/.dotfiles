return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      swift = { "swiftformat" },
      scss = { "prettier", "cssls" },
      css = { "prettier", "cssls" },
    },
  },
}
