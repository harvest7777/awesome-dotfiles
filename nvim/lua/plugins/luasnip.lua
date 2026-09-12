return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  event = 'InsertEnter',
  config = function()
    local ls = require('luasnip')

    ls.setup({
      -- math snippets are only worth it if they fire without a trigger key
      enable_autosnippets = true,
      -- leaving a snippet backwards and re-entering it keeps the tabstops alive
      history = true,
      delete_check_events = 'TextChanged',
    })

    -- friendly-snippets (already a blink dependency) is in the vscode format
    require('luasnip.loaders.from_vscode').lazy_load()
    vim.keymap.set({ 'i', 's' }, '<C-l>', function()
      if ls.choice_active() then ls.change_choice(1) end
    end, { desc = 'LuaSnip: next choice' })
  end,
}
