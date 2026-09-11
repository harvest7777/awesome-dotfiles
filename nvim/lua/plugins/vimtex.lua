return {
  'lervag/vimtex',
  -- pinned: vimtex master now requires neovim 0.12.4 and this machine runs
  -- 0.12.2, so it refuses to load. v2.18 only needs 0.10.
  tag = 'v2.18',
  lazy = false, -- vimtex must be loaded before the first tex buffer opens
  init = function()
    -- Skim is the only macOS viewer with working forward/inverse search.
    -- Without it, fall back to whatever `open` picks (usually Preview).
    if vim.fn.isdirectory('/Applications/Skim.app') == 1 then
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1 -- scroll the PDF to the cursor after each build
      vim.g.vimtex_view_skim_activate = 1
    else
      vim.g.vimtex_view_method = 'general'
      vim.g.vimtex_view_general_viewer = 'open'
    end

    -- box warnings fire constantly on math-heavy documents and never matter
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
