local M = {}

function M.setup(buf)
  -- many C/C++ codebases prefer tabs (adjust to taste)
  vim.bo[buf].expandtab    = false
  vim.bo[buf].tabstop      = 4
  vim.bo[buf].shiftwidth   = 4
  vim.bo[buf].softtabstop  = 4

  local ok, loader = pcall(require, "luasnip.loaders.from_lua")
  if ok then
    loader.load({
      paths = vim.fn.stdpath("config") .. "/lua/snippets/cpp",
      include = { "cpp", "c" },
    })
  end
end

return M
