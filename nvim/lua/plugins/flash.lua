return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function(_, opts)
    require('flash').setup(opts)
    -- ]s ]d ]c ]b, plus ; and , repeating them as well as f/t
    require('repeat_moves').setup()
  end,
  keys = {
    { 's',     mode = { 'n', 'x', 'o' }, function() require('flash').jump() end,              desc = 'Jump to label' },
    { 'S',     mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end,        desc = 'Select syntax node' },
    { 'r',     mode = 'o',               function() require('flash').remote() end,            desc = 'Act on a jump target' },
    { 'R',     mode = { 'o', 'x' },      function() require('flash').treesitter_search() end, desc = 'Select syntax node at search match' },
    { '<c-s>', mode = { 'c' },           function() require('flash').toggle() end,            desc = 'Toggle jump labels in search' },
  },
}
