-- ~/.config/nvim/lua/plugins/init.lua
-- Standard lazy.nvim bootstrap + plugin list

local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Auto-install lazy.nvim if missing
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin list
require("lazy").setup({
  -------------------
  -- UI / Appearance
  -------------------
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup { options = { theme = "gruvbox" } }
    end
  },

  -------------------
  -- Editor Utilities
  -------------------
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "numToStr/Comment.nvim", config = true },

  -------------------
  -- LSP / Completion
  -------------------
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", dependencies = { "mason.nvim" }, config = true },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp", dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip"
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  },

  -------------------
  -- Git
  -------------------
  { "lewis6991/gitsigns.nvim", config = true },
}, {
  install = { colorscheme = { "gruvbox" } },
  checker = { enabled = true }, -- auto-check for plugin updates
})

