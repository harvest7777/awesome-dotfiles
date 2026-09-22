return {
  'lewis6991/gitsigns.nvim',
  opts = {
    current_line_blame = true,
    preview_config = {
      border = 'rounded',
      style = 'minimal',
      relative = 'cursor',
      row = 1,
      col = 0,
      focusable = true,
    },
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end
      map('n', ']c', function() gs.nav_hunk('next') end, 'Next hunk')
      map('n', '[c', function() gs.nav_hunk('prev') end, 'Prev hunk')
      map('n', '<leader>hd', gs.preview_hunk, 'Preview hunk inline')
      map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
      map('n', '<leader>hb', gs.blame_line, 'Blame line')
    end,
  },
}
