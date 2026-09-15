return
{
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets', 'L3MON4D3/LuaSnip' },

  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
        preset = 'super-tab',
        ['<C-Space>'] = {},
      },

    enabled = function() return not vim.tbl_contains({ "text", "markdown" }, vim.bo.filetype) end,

    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = { documentation = { auto_show = false } },

    snippets = { preset = 'luasnip' },
    signature = {
      enabled = true,
      window = {
        border = 'rounded',
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = {
          -- clangd's if/for patterns don't indent the body; friendly-snippets' do
          transform_items = function(_, items)
            if not vim.tbl_contains({ 'c', 'cpp' }, vim.bo.filetype) then return items end
            local snippet = require('blink.cmp.types').CompletionItemKind.Snippet
            return vim.tbl_filter(function(item) return item.kind ~= snippet end, items)
          end,
        },
      },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
