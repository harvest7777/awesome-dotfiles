-- Makes the ]x / [x jumps repeatable with ; and , the same way f/t are.
--
-- Flash owns f F t T and its own ; , repeat. This wraps those so that ; and ,
-- repeat whichever happened last: a Flash f/t, or one of the bracket jumps
-- below (via nvim-treesitter-textobjects' repeatable_move). Like Vim, ; goes
-- the same direction as the original jump and , the opposite one.
--
-- Call setup() after Flash has set up its char-mode mappings.

local M = {}

local last = 'char' -- 'char' (Flash f/t) or 'bracket'

local function repeatable(move)
  local rm = require('nvim-treesitter-textobjects.repeatable_move')
  local repeat_move = rm.make_repeatable_move(function(opts)
    last = 'bracket'
    move(opts.forward, vim.v.count1)
  end)
  return function(forward)
    return function() repeat_move({ forward = forward }) end
  end
end

local moves = {
  s = { desc = 'misspelled word', move = function(forward, count)
    vim.cmd('normal! ' .. count .. (forward and ']s' or '[s'))
  end },
  d = { desc = 'diagnostic', move = function(forward, count)
    vim.diagnostic.jump({ count = forward and count or -count, float = { border = 'rounded' } })
  end },
  c = { desc = 'git hunk', move = function(forward, count)
    local ok, gs = pcall(require, 'gitsigns')
    if ok then gs.nav_hunk(forward and 'next' or 'prev', { count = count }) end
  end },
  b = { desc = 'buffer', move = function(forward, count)
    for _ = 1, count do
      vim.cmd(forward and 'BufferLineCycleNext' or 'BufferLineCyclePrev')
    end
  end },
}

function M.setup()
  for key, m in pairs(moves) do
    local jump = repeatable(m.move)
    vim.keymap.set('n', ']' .. key, jump(true), { desc = 'Next ' .. m.desc })
    vim.keymap.set('n', '[' .. key, jump(false), { desc = 'Prev ' .. m.desc })
  end

  local rm = require('nvim-treesitter-textobjects.repeatable_move')
  local modes = { 'n', 'x', 'o' }

  -- Flash's own mappings, so they can be wrapped rather than replaced
  local flash = {}
  for _, key in ipairs({ 'f', 'F', 't', 'T', ';', ',' }) do
    flash[key] = vim.fn.maparg(key, 'n', false, true).callback
  end

  for _, key in ipairs({ 'f', 'F', 't', 'T' }) do
    if flash[key] then
      vim.keymap.set(modes, key, function()
        last = 'char'
        flash[key]()
      end, { desc = 'Flash ' .. key })
    end
  end

  vim.keymap.set(modes, ';', function()
    if last == 'bracket' then rm.repeat_last_move() elseif flash[';'] then flash[';']() end
  end, { desc = 'Repeat last f/t or ]x jump' })
  vim.keymap.set(modes, ',', function()
    if last == 'bracket' then rm.repeat_last_move_opposite() elseif flash[','] then flash[',']() end
  end, { desc = 'Repeat last f/t or ]x jump backwards' })
end

return M
