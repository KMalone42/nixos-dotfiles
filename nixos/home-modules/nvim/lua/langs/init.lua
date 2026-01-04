local M = {}

-- map FileType → module
local map = {
  python = "langs.py",
  nix    = "langs.nix",
  cpp    = "langs.cpp",
  c      = "langs.cpp",  -- reuse cpp settings for C
}

function M.setup()
  local grp = vim.api.nvim_create_augroup("LangsSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = grp,
    pattern = vim.tbl_keys(map),
    callback = function(args)
      -- buffer-safe require + call
      local ok, mod = pcall(require, map[args.match])
      if ok and type(mod.setup) == "function" then
        mod.setup(args.buf)
      end
    end,
  })
end

return M
