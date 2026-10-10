-- Faint vertical guides at each indent level; the current scope is a bit
-- darker. Thinnest line character, colors just off catppuccin latte's base.
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = 'VeryLazy',
  config = function()
    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'IblIndentFaint', { fg = '#dce0e8' })
      vim.api.nvim_set_hl(0, 'IblScopeFaint', { fg = '#ccd0da' })
    end)

    require('ibl').setup({
      indent = { char = '▏', highlight = 'IblIndentFaint' },
      scope = { char = '▏', highlight = 'IblScopeFaint' },
    })
  end,
}
