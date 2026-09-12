-------------------------------------------------------------------------------
-- PR links
-------------------------------------------------------------------------------
local function read_cache(cache_path)
  local f = io.open(cache_path, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  if content == "" then
    return {}
  end
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

vim.keymap.set('n', '<leader>ip', function()
  local opts = { prompt = 'Enter pr link', scope = 'buffer' }

  vim.ui.input(opts, function(input)
    local valid = input ~= '' and input ~= nil
    if valid then
      local state_path = vim.fs.joinpath(vim.fn.stdpath("state"), "pr_links.json")

      local data = read_cache(state_path)

      local cwd = vim.fn.getcwd()
      local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
      local cwd_branch_name_key = cwd .. "-" .. branch_name

      data[cwd_branch_name_key] = input

      local f = io.open(state_path, "w")
      if not f then
        return
      end
      f:write(vim.json.encode(data))
      f:close()
      vim.notify('Saved ' .. input)
    end
  end)
end, { desc = 'Save PR to branch or worktree' })

vim.keymap.set('n', '<leader>gp', function()
  local cwd = vim.fn.getcwd()
  local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  local cwd_branch_name_key = cwd .. "-" .. branch_name
  local state_path = vim.fs.joinpath(vim.fn.stdpath("state"), "pr_links.json")
  local data = read_cache(state_path)
  local pr_link = data[cwd_branch_name_key]
  if not pr_link then
    vim.notify('No saved link for this branch', vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", pr_link)
  vim.notify('Copied ' .. pr_link)
end, { desc = 'Copy saved link' })

-------------------------------------------------------------------------------
-- File actions
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>bx', function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.cmd('bp')
  vim.api.nvim_buf_delete(bufnr, {})
end, { desc = "Delete current buffer safely" })
vim.keymap.set('n', '<leader>ww', '<cmd>w<cr>', { desc = 'Write file' })
vim.keymap.set('n', '<leader>wa', '<cmd>wa<cr>', { desc = 'Write all' })
vim.keymap.set('n', '<leader>qq', '<cmd>qa!<cr>', { desc = 'Quit all' })

-------------------------------------------------------------------------------
-- Neogit
-------------------------------------------------------------------------------
local function real_path_for_current_buffer()
  local name = vim.api.nvim_buf_get_name(0)
  local rel = name:match("^neogit://[^/]+/(.+)$")
  if not rel then
    return nil
  end
  local root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
  if vim.v.shell_error ~= 0 or root == "" then
    return nil
  end
  return root .. "/" .. rel
end

vim.keymap.set('n', '<leader>p', function()
  vim.fn.setreg("+", real_path_for_current_buffer() or vim.fn.expand("%:p"))
end, { desc = 'Copy absolute path' })

vim.keymap.set('n', '<leader>P', function()
  local abs = real_path_for_current_buffer()
  local rel = abs and vim.fn.fnamemodify(abs, ":~:.") or vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  vim.fn.setreg("+", rel)
end, { desc = 'Copy relative path' })

vim.keymap.set('n', '<leader>nf', function()
  local real = real_path_for_current_buffer()
  if not real then
    vim.notify('Not in a Neogit commit-preview buffer', vim.log.levels.WARN)
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd('edit ' .. vim.fn.fnameescape(real))
  local line = math.min(cursor[1], vim.api.nvim_buf_line_count(0))
  local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
  local col = math.min(cursor[2], #line_text)
  pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
end, { desc = 'Open real file from Neogit commit preview' })

-------------------------------------------------------------------------------
-- Notes
-------------------------------------------------------------------------------
local function notes_path()
  local root = vim.trim(vim.fn.system("git rev-parse --show-toplevel"))
  local key = (vim.v.shell_error == 0 and root ~= "") and root
      or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  key = key:gsub("[^%w%-_.]", "-")
  local notes_dir = vim.fs.joinpath(vim.uv.os_homedir(), "notes")
  vim.fn.mkdir(notes_dir, "p")
  return vim.fs.joinpath(notes_dir, key .. "-notes.md")
end

local notes_cursor_cache_path = vim.fs.joinpath(vim.fn.stdpath("state"), "notes_cursor.json")

local function read_notes_cursor_cache()
  local f = io.open(notes_cursor_cache_path, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  if content == "" then
    return {}
  end
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

local function save_notes_cursor(path, cursor)
  local data = read_notes_cursor_cache()
  data[path] = { cursor[1], cursor[2] }
  local f = io.open(notes_cursor_cache_path, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(data))
  f:close()
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      if name:match("%-notes%.md$") then
        pcall(save_notes_cursor, name, vim.api.nvim_win_get_cursor(win))
      end
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified
          and vim.api.nvim_buf_get_name(buf):match("%-notes%.md$") then
        pcall(vim.api.nvim_buf_call, buf, function() vim.cmd("write") end)
      end
    end
  end,
})

vim.keymap.set('n', '<leader>md', function()
  local path = notes_path()
  local is_new = vim.fn.filereadable(path) == 0

  local buf = vim.fn.bufadd(path)
  local loaded_ok, load_err = pcall(vim.fn.bufload, buf)
  if not loaded_ok then
    vim.notify("Couldn't open notes: " .. tostring(load_err), vim.log.levels.ERROR)
    return
  end

  if is_new then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# Notes", "" })
    local write_ok, write_err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd("write") end)
    if not write_ok then
      vim.notify("Couldn't save new notes file: " .. tostring(write_err), vim.log.levels.ERROR)
      return
    end
    vim.notify("Created " .. path)
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.8)
  local notes_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Notes ",
    title_pos = "center",
  })
  vim.wo[notes_win].winhighlight = "Normal:NormalFloat"
  vim.wo[notes_win].wrap = true
  vim.wo[notes_win].linebreak = true

  local saved = read_notes_cursor_cache()[path]
  if saved then
    local line = math.min(saved[1], vim.api.nvim_buf_line_count(buf))
    local line_text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ""
    local col = math.min(saved[2], #line_text)
    pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
  end

  local notes_autocmd_group = vim.api.nvim_create_augroup("notes_cursor_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = notes_autocmd_group,
    buffer = buf,
    callback = function()
      pcall(save_notes_cursor, path, vim.api.nvim_win_get_cursor(0))
      if vim.bo[buf].modified then
        pcall(vim.cmd, "write")
      end
    end,
  })

  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end, { desc = "Open this worktree's notes.md (floating)" })

-------------------------------------------------------------------------------
-- Editor toggles
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>lb', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
end, { desc = 'Toggle wrap + linebreak' })

-------------------------------------------------------------------------------
-- LSP
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
vim.keymap.set('i', '<C-Space>', function() vim.lsp.buf.signature_help({ border = 'rounded', max_width = 80 }) end,
  { desc = 'Signature help' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = desc })
    end
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('gr', vim.lsp.buf.references, 'Go to references')
    map('gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('K', function() vim.lsp.buf.hover({ border = 'rounded', max_width = 80 }) end, 'Hover docs')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('[d', function() vim.diagnostic.jump({ count = -1, float = { border = 'rounded' } }) end, 'Prev diagnostic')
    map(']d', function() vim.diagnostic.jump({ count = 1, float = { border = 'rounded' } }) end, 'Next diagnostic')
  end,
})

-------------------------------------------------------------------------------
-- Clipboard and buffer navigation
-------------------------------------------------------------------------------
vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set('n', '<Tab>', '<cmd>b#<cr>')

-------------------------------------------------------------------------------
-- Scrolling and tabs
-------------------------------------------------------------------------------
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', 'j', 'jzz', { desc = 'Down and center' })
vim.keymap.set('n', 'k', 'kzz', { desc = 'Up and center' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Next match and center' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Prev match and center' })

vim.keymap.set('n', '<leader>gx', '<cmd>tabclose<cr>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>gn', '<cmd>tabnew<cr>', { desc = 'New tab' })

-------------------------------------------------------------------------------
-- Noice
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>nd', '<cmd>Noice dismiss<cr>', { desc = 'Dismiss Noice toasts' })
vim.keymap.set('n', '<leader>na', '<cmd>Noice all<cr>', { desc = 'View all messages' })
vim.keymap.set('n', '<leader>nl', '<cmd>Noice last<cr>', { desc = 'View last message' })

-------------------------------------------------------------------------------
-- Window management
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>w|', vim.cmd.vsplit)
vim.keymap.set('n', '<leader>w-', vim.cmd.split)
vim.keymap.set('n', '<leader>wd', vim.cmd.close)

vim.keymap.set('n', '<leader>wn', '<C-w>w')
vim.keymap.set('n', '<leader>wh', '<C-w>h')
vim.keymap.set('n', '<leader>wj', '<C-w>j')
vim.keymap.set('n', '<leader>wk', '<C-w>k')
vim.keymap.set('n', '<leader>wl', '<C-w>l')

vim.keymap.set('n', '<C-Up>', '<cmd>resize +5<cr>', { desc = 'Increase height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -5<cr>', { desc = 'Decrease height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -5<cr>', { desc = 'Decrease width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +5<cr>', { desc = 'Increase width' })

-------------------------------------------------------------------------------
-- Telescope
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>fn', function()
  local dir = vim.fn.getcwd()
  require('telescope.builtin').find_files({
    prompt_title = 'Find files in ' .. vim.fn.fnamemodify(dir, ':~'),
    cwd = dir,
  })
end, { desc = 'Find files in cwd' })

vim.keymap.set('n', '<leader>dn', function()
  local root = vim.fn.getcwd()
  require('telescope.builtin').find_files({
    prompt_title = 'Find directories (from ' .. vim.fn.fnamemodify(root, ':~') .. ')',
    find_command = { 'fd', '--type', 'd', '--base-directory', root },
    cwd = root,
  })
end, { desc = 'Find directory in cwd' })

-------------------------------------------------------------------------------
-- Yazi
-------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>no', function()
  local current_file_path = vim.fn.resolve(vim.fn.expand('%:p'))
  require('yazi').yazi(nil, current_file_path, { reveal_path = current_file_path })
end, { desc = 'Reveal current file' })
local function explorer_root()
  local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  return (vim.v.shell_error == 0 and root) or vim.fn.getcwd()
end

vim.keymap.set('n', '<leader>nr', function()
  require('yazi').yazi(nil, explorer_root())
end, { desc = 'Open explorer at git root' })

vim.keymap.set('n', '<leader>ne', function()
  local dir = vim.g.yazi_last_directory
  if not dir or vim.fn.isdirectory(dir) == 0 then
    dir = explorer_root()
  end
  require('yazi').yazi(nil, dir)
end, { desc = 'Open explorer where it was last closed' })

-------------------------------------------------------------------------------
-- Todo
-------------------------------------------------------------------------------
local function toggle_todo_line(line)
  if line:match('%[x%]') then
    return (line:gsub('%[x%]', '[ ]', 1))
  elseif line:match('%[ %]') then
    return (line:gsub('%[ %]', '[x]', 1))
  end
  return line
end

local function add_todo_line(line)
  if line:match('^%s*%-%s*%[[ xX]%]') then
    return line -- already a checkbox, leave it alone
  end
  if line:match('^%s*$') then
    return '- [ ] '
  end
  return '- [ ] ' .. line
end

-- '< and '> only get updated to the just-made selection's bounds once you
-- actually *leave* Visual mode -- and a Lua function bound straight to a
-- visual-mode keymap runs while still IN Visual mode (mode() == 'v'/'V'),
-- before that update happens, so line("'<")/line("'>") read stale/zeroed
-- marks. The classic fix: map to a literal `:` command instead of a Lua
-- function. Pressing `:` from Visual mode is itself what makes Vim leave
-- Visual mode and set the marks -- <C-u> then clears the `'<,'>` range
-- Vim auto-inserts on the command line, since we read the marks ourselves.
local function apply_to_visual_selection(transform)
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  for lnum = start_line, end_line do
    vim.fn.setline(lnum, transform(vim.fn.getline(lnum)))
  end
end

vim.keymap.set('n', '<leader>x', function()
  vim.api.nvim_set_current_line(toggle_todo_line(vim.api.nvim_get_current_line()))
end, { desc = 'Toggle todo' })

_G.__todo_toggle_range = function() apply_to_visual_selection(toggle_todo_line) end
vim.keymap.set('v', '<leader>x', ':<C-u>lua __todo_toggle_range()<CR>',
  { silent = true, desc = 'Toggle todo (selection)' })

vim.keymap.set('n', '<leader>td', function()
  vim.api.nvim_set_current_line(add_todo_line(vim.api.nvim_get_current_line()))
end, { desc = 'Add todo' })

_G.__todo_add_range = function() apply_to_visual_selection(add_todo_line) end
vim.keymap.set('v', '<leader>td', ':<C-u>lua __todo_add_range()<CR>',
  { silent = true, desc = 'Add todo (selection)' })

-------------------------------------------------------------------------------
-- Folding
-------------------------------------------------------------------------------
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})
