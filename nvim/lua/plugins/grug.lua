return
{
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
      windowCreationCommand = 'enew | lua vim.bo.buflisted = false',
    })
    vim.keymap.set('n', '<leader>gn', function()
      local grug_far = require('grug-far')
      if grug_far.has_instance('main') then
        grug_far.get_instance('main'):open()
      else
        grug_far.open({ instanceName = 'main' })
      end
    end, { desc = 'Open Grug' })
  end
}
