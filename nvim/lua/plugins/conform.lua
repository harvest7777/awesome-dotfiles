return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      jsonnet = { "jsonnetfmt" },
      -- tex-fmt over latexindent: latexindent ships with TeX Live but needs
      -- Perl modules the system perl doesn't have, and it's slow enough to
      -- blow the format-on-save budget on a long document.
      tex = { "tex-fmt" },
    },
  },
}
