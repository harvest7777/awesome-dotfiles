-- Animated scrolling for <C-u> <C-d> <C-b> <C-f> <C-y> <C-e> zt zz zb.
-- <C-d>/<C-u> also re-center the cursor once the animation ends.
local function scroll_and_center(fn)
  return function()
    require('neoscroll')[fn]({ duration = 200, info = 'center' })
  end
end

return {
  'karb94/neoscroll.nvim',
  event = 'VeryLazy',
  opts = {
    -- <C-d>/<C-u> are mapped below so they can center afterwards
    mappings = { '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
    easing = 'quadratic',
    post_hook = function(info)
      if info == 'center' then vim.cmd('normal! zz') end
    end,
  },
  keys = {
    { '<C-d>', scroll_and_center('ctrl_d'), mode = { 'n', 'x' }, desc = 'Scroll down and center' },
    { '<C-u>', scroll_and_center('ctrl_u'), mode = { 'n', 'x' }, desc = 'Scroll up and center' },
  },
}
