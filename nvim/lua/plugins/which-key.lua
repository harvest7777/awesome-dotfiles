-- Pause after a prefix like <leader>, g, z or [ to see what can follow
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    -- Compact box in the bottom-right corner with a rounded border
    preset = 'helix',
  },
}
