-- nvim/lua/langs/lsp.lua
local M = {}

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- toggle this in your config somewhere:
-- vim.g.langs_use_mason = false  -- on NixOS you'll likely keep this false
local use_mason = vim.g.langs_use_mason ~= false

-- track which servers we’ve already set up
local configured = {}

---@param server string
---@param opts table|nil
function M.ensure(server, opts)
  if configured[server] then
    return
  end
  configured[server] = true

  opts = opts or {}
  opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})

  -- If you *really* want Mason to handle binaries, set use_mason=true
  if not use_mason then
    -- NixOS path-first: only configure if binary exists on PATH
    local cmd = opts.cmd
    if not cmd and vim.fn.executable(server) == 1 then
      cmd = { server }
    end
    if cmd then
      opts.cmd = cmd
    end
  end

  lspconfig[server].setup(opts)
end

return M
