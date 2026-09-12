return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  opts = {
    pipe_table = { style = 'full', preset = 'round', cell = 'trimmed' },
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)

    local function fix_float_bg_bleed()
      local fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg
      vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = fg, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'RenderMarkdownTableRow', { fg = fg, bg = 'NONE' })
    end

    fix_float_bg_bleed()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('RenderMarkdownFixFloatBg', { clear = true }),
      callback = fix_float_bg_bleed,
    })
  end,
}
