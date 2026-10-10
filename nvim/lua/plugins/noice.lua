return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    views = {
      popup = {
        size = { width = "80%", height = "70%" },
      },
      -- Nvim 0.12 sends the question and the [Y]es/(N)o buttons as one line;
      -- noice's confirm formatter expects them on separate lines and drops
      -- the question, so show the raw text instead
      confirm = {
        format = { "{message}" },
        -- Wrap long file paths instead of cutting off the buttons
        size = { width = 80, height = "auto" },
        win_options = { wrap = true },
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
