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

-- Built-in ]s / [s get stuck in some Markdown files (e.g. [s can't go back
-- past certain lines, ]s doesn't wrap), so find misspellings directly:
-- check each line with vim.spell.check, skip words treesitter marks @nospell
-- (code), and wrap around the buffer like 'wrapscan'.
local function spell_targets()
  local targets = {}
  for row, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for _, hit in ipairs(vim.spell.check(line)) do
      local col = hit[3] - 1
      local nospell = false
      for _, cap in ipairs(vim.treesitter.get_captures_at_pos(0, row - 1, col)) do
        if cap.capture == 'nospell' then nospell = true end
      end
      if not nospell then table.insert(targets, { row, col }) end
    end
  end
  return targets
end

local function spell_jump(forward, count)
  if not vim.wo.spell then return end
  local targets = spell_targets()
  if #targets == 0 then return end
  local cur = vim.api.nvim_win_get_cursor(0)
  local function after(t) return t[1] > cur[1] or (t[1] == cur[1] and t[2] > cur[2]) end
  local function before(t) return t[1] < cur[1] or (t[1] == cur[1] and t[2] < cur[2]) end

  -- index of the first target past the cursor in the jump direction
  local idx
  if forward then
    idx = #targets + 1
    for i, t in ipairs(targets) do
      if after(t) then idx = i break end
    end
    idx = idx + count - 1
  else
    idx = 0
    for i = #targets, 1, -1 do
      if before(targets[i]) then idx = i break end
    end
    idx = idx - count + 1
  end
  idx = (idx - 1) % #targets + 1 -- wrap around
  vim.api.nvim_win_set_cursor(0, targets[idx])
end

local moves = {
  s = { desc = 'misspelled word', move = spell_jump },
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
