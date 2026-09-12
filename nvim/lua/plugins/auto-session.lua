return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  init = function()
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        if package.loaded['neogit'] then
          pcall(require('neogit').close)
        end
      end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 then
          require('persistence').load()
          vim.schedule(function()
            vim.cmd('nohlsearch')

            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              local name = vim.api.nvim_buf_get_name(buf)
              if name ~= '' and vim.fn.isdirectory(name) == 1 then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end)
        end
      end,
    })
  end,
}
