return
{
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  init = function()
    vim.g.no_plugin_maps = true
  end,
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v',
          ['@function.outer'] = 'V',
        },
        include_surrounding_whitespace = false,
      },
    }

    vim.keymap.set({ "x", "o" }, "af", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ai", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ii", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
    end)
  end,
}
