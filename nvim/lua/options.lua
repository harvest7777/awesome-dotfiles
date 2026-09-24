vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.scrolloff = 10
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.cmdheight = 0
vim.opt.foldlevel = 99
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.undofile = true -- persistent undo across sessions
vim.opt.clipboard = 'unnamedplus'
vim.opt.iskeyword:append("-")

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    vim.cmd("checktime")
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

local cursor_positions = {}

vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    cursor_positions[vim.api.nvim_get_current_buf()] = vim.api.nvim_win_get_cursor(0)
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local pos = cursor_positions[buf]
    if pos then
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    else
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_count = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= line_count then
        vim.api.nvim_win_set_cursor(0, mark)
      end
    end
  end,
})

vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = '■',
    format = function(diag)
      return diag.message:sub(1, 60) .. (diag.message:len() > 55 and '...' or '')
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})
