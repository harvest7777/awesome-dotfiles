return {
  'lervag/vimtex',
  tag = 'v2.18',
  lazy = false,
  init = function()
    if vim.fn.isdirectory('/Applications/Skim.app') == 1 then
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    else
      vim.g.vimtex_view_method = 'general'
      vim.g.vimtex_view_general_viewer = 'open'
    end

    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      'Underfull \\\\hbox',
      'Overfull \\\\hbox',
      'LaTeX Font Warning',
    }
  end,
  keys = {
    { '<leader>ll', '<cmd>VimtexCompile<cr>',   ft = 'tex', desc = 'LaTeX: toggle continuous compile' },
    { '<leader>lv', '<cmd>VimtexView<cr>',      ft = 'tex', desc = 'LaTeX: view PDF' },
    { '<leader>le', '<cmd>VimtexErrors<cr>',    ft = 'tex', desc = 'LaTeX: errors' },
    { '<leader>lt', '<cmd>VimtexTocToggle<cr>', ft = 'tex', desc = 'LaTeX: table of contents' },
    { '<leader>lc', '<cmd>VimtexClean<cr>',     ft = 'tex', desc = 'LaTeX: clean aux files' },
    { '<leader>ls', '<cmd>VimtexStop<cr>',      ft = 'tex', desc = 'LaTeX: stop compile' },
  },
}
