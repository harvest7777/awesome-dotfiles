-- Close a buffer only if it has no unsaved changes
local function close_if_saved(bufnr)
  if vim.bo[bufnr].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
    vim.notify('Not closing ' .. (name ~= '' and name or '[No Name]') .. ': unsaved changes',
      vim.log.levels.WARN)
    return
  end
  vim.cmd('bdelete ' .. bufnr)
end

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  keys = {
    { '<leader>bm', '<cmd>BufferLineMoveNext<cr>',    desc = 'Move buffer right' },
    { '<leader>bM', '<cmd>BufferLineMovePrev<cr>',    desc = 'Move buffer left' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>',   desc = 'Pin buffer' },
    { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>',   desc = 'Close left' },
    { '<leader>br', '<cmd>BufferLineCloseRight<cr>',  desc = 'Close right' },
    { '<leader>bb', '<cmd>BufferLinePick<cr>',        desc = 'Pick buffer' },
    { '<leader>bd', '<cmd>BufferLinePickClose<cr>',   desc = 'Pick buffer to close' },
    { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close other buffers' },
  },
  opts = {
    options = {
      -- switch to 'tabs' to list tab pages instead of open buffers
      mode = 'buffers',
      -- Default is bdelete!, which discards unsaved changes; skip those instead
      close_command = close_if_saved,
      right_mouse_command = close_if_saved,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(count, level)
        return (level:match('error') and ' ' or ' ') .. count
      end,
      separator_style = 'thin',
      indicator = { style = 'underline' },
      always_show_bufferline = true,
      hover = { enabled = true, delay = 200, reveal = { 'close' } },
    },
  },
}
