return
{
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "sindrets/diffview.nvim",
    "esmuellert/codediff.nvim",

    "m00qek/baleia.nvim",

    "nvim-telescope/telescope.nvim",
    "ibhagwan/fzf-lua",
    "nvim-mini/mini.pick",
    "folke/snacks.nvim",
  },
  cmd = "Neogit",
  opts = {
    commit_view = {
      kind = "replace",
    },
  },
  init = function()
    -- Neogit creates its buffers with bufhidden=wipe. With commit_view.kind
    -- set to "replace", opening a commit hides the status buffer, which then
    -- gets wiped -- so closing the commit view finds its saved old_buf invalid
    -- and falls back to `enew`, dropping you in a [No Name] buffer instead of
    -- back at the status view. Keeping the status buffer alive while hidden
    -- lets it be restored.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(args)
        vim.bo[args.buf].bufhidden = "hide"
      end,
    })
  end,
  keys = {
    {
      "<leader>gg",
      function()
        -- Neogit defaults to resolving the repo with `git rev-parse` from "."
        -- (nvim's cwd), so opening a file inside a *nested* repo shows the
        -- outer repo's status. Resolve from the current buffer instead.
        local name = vim.api.nvim_buf_get_name(0)
        local dir
        if name ~= "" and not name:match("^%w+://") then
          dir = vim.fn.isdirectory(name) == 1 and name or vim.fn.fnamemodify(name, ":p:h")
        end
        require("neogit").open({ cwd = dir or vim.uv.cwd() })
      end,
      desc = "Show Neogit UI",
    },
  },
}
