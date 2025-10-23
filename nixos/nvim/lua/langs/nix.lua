local M = {}

function M.setup(buf)
  vim.bo[buf].expandtab    = true
  vim.bo[buf].tabstop      = 2
  vim.bo[buf].shiftwidth   = 2
  vim.bo[buf].softtabstop  = 2

  local ok, loader = pcall(require, "luasnip.loaders.from_lua")
  if ok then
    loader.load({
      paths = vim.fn.stdpath("config") .. "/lua/snippets/nix",
      include = { "nix" },
    })
  end
end

return M
