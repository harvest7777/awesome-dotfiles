-- Pause after a prefix like <leader>, g, z or [ to see what can follow
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    -- Compact box in the bottom-right corner with a rounded border
    preset = 'helix',
    -- Names for the <leader> prefixes, shown instead of "+N keymaps"
    spec = {
      { '<leader>b', group = 'buffer' },
      { '<leader>c', group = 'code' },
      { '<leader>d', group = 'directory' },
      { '<leader>f', group = 'find' },
      { '<leader>g', group = 'git / grug / tab' },
      { '<leader>h', group = 'git hunk' },
      { '<leader>i', group = 'PR link' },
      { '<leader>l', group = 'wrap / latex' },
      { '<leader>n', group = 'yazi / messages' },
      { '<leader>o', group = 'open' },
      { '<leader>q', group = 'quit' },
      { '<leader>r', group = 'rename' },
      { '<leader>t', group = 'todo' },
      { '<leader>w', group = 'window / write' },
    },
  },
}
