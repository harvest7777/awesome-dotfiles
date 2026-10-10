-- Nvim 0.12 sends a confirm dialog's question and its [Y]es/(N)o buttons as
-- one line. Noice's built-in confirm formatter expects them on separate lines
-- and drops the question, so this one splits them itself: the question (file
-- paths shortened to their name) on top, the buttons centered underneath.
local function confirm_oneline(message, _, input)
  local text = input:content():gsub('%s+$', '')
  local question, buttons = text:match('^(.-)%s*(%[.*):$')
  if not question then
    return message:append(input)
  end
  question = question:gsub('"([^"]+)"', function(path)
    return '"' .. vim.fn.fnamemodify(path, ':t') .. '"'
  end)

  message:append(question)
  message:newline()
  message:newline()
  local choices = vim.split(buttons, ', ')
  for i, choice in ipairs(choices) do
    local hl = choice:find('%[') and 'NoiceFormatConfirmDefault' or 'NoiceFormatConfirm'
    message:append(' ' .. choice .. ' ', hl)
    if i < #choices then message:append(' ') end
  end

  local NoiceText = require('noice.text')
  local padding = math.floor((message:width() - message:last_line():width()) / 2)
  table.insert(message:last_line()._texts, 1, NoiceText((' '):rep(padding)))
end

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  config = function(_, opts)
    require('noice.text.format.formatters').confirm_oneline = confirm_oneline
    require('noice').setup(opts)
  end,
  opts = {
    views = {
      popup = {
        size = { width = "80%", height = "70%" },
      },
      confirm = {
        format = { "{confirm_oneline}" },
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
