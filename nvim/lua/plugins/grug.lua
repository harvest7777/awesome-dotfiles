return
{
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
      windowCreationCommand = 'enew | lua vim.bo.buflisted = false; vim.b.__grug_far_buffer = true',
      -- Open result files in the window Grug replaced instead of creating a split.
      -- Grug still reuses an already-loaded buffer when one exists.
      openTargetWindow = {
        preferredLocation = 'prev',
      },
    })

    -- A new file opened with Goto reuses Grug's buffer, so make it visible
    -- in bufferline once it becomes a normal file buffer.
    vim.api.nvim_create_autocmd('BufFilePost', {
      callback = function(args)
        if not vim.b[args.buf].__grug_far_buffer then
          return
        end

        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == '' then
            vim.bo[args.buf].buflisted = true
            vim.b[args.buf].__grug_far_buffer = nil
          end
        end)
      end,
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
