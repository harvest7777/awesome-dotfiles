return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    views = {
      popup = {
        size = { width = "80%", height = "70%" },
      },
    },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
      view_history = "popup",
    },
    commands = {
      all = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = {},
      },
    },
    lsp = {
      progress = {
        enabled = false,
      },
      hover = {
        enabled = false
      },
      signature = {
        enabled = false,
      },
    },
    notify = {
      enabled = true,
      view = "mini",
    },
    presets = {
      command_palette = false,
      long_message_to_split = true,
      inc_rename = false,
    },
  },
}
