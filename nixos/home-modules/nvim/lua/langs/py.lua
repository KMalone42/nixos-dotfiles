-- ~/.config/nvim/lua/langs/py.lua
local M = {}
local did_setup = false

local lsp = require("langs.lsp")

function M.setup(buf)
  -- buffer-local options (run on every Python buffer)
  vim.bo[buf].expandtab    = true
  vim.bo[buf].tabstop      = 4
  vim.bo[buf].shiftwidth   = 4
  vim.bo[buf].softtabstop  = 4

  -- Everything below only runs once (first Python buffer opened)
  if did_setup then return end
  did_setup = true

  -- Basic keymaps (only set once)
  local map = vim.keymap.set
  map({ "i", "s" }, "<C-k>", function() ls.expand_or_jump() end, { silent = true, desc = "LuaSnip expand/jump" })
  map({ "i", "s" }, "<C-j>", function() ls.jump(-1) end,         { silent = true, desc = "LuaSnip jump back" })

  -- Optional but nice: enable updating extmarks when leaving/entering insert
  ls.config.setup({
    update_events = "TextChanged,TextChangedI",
  })

  -----------------------------------------------------------------------------
  --- LSP setup
  -----------------------------------------------------------------------------

  local function on_attach(client, bufnr)
    -- per-buffer LSP keymaps
    local function buf_map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
    end

    buf_map("gd", vim.lsp.buf.definition, "Go to definition")
    buf_map("K",  vim.lsp.buf.hover,      "Hover docs")
    buf_map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    buf_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end

  lsp.ensure("pyright", {
    on_attach = on_attach,
    -- for NixOS, you can be explicit if needed:
    -- cmd = { "pyright-langserver", "--stdio" },

    -- example settings (optional)
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoImportCompletions = true,
        },
      },
    },
  })

  -----------------------------------------------------------------------------
  --- LuaSnip
  --- -------------------------------------------------------------------------

  local ok, ls = pcall(require, "luasnip")
  if not ok then return end

  -- Register the snippet for Python
  local s  = ls.snippet
  local t  = ls.text_node
  local i  = ls.insert_node

  ls.add_snippets("python", {
    s("qargparse", {
      t({
        "import argparse",
        "",
        "parser = argparse.ArgumentParser(",
        "    prog='",
      }), i(1, "ProgramName"), t({
        "',",
        "    description='",
      }), i(2, "What the program does"), t({
        "',",
        "    usage='",
      }), i(3, "ProgramName [options]"), t({
        "',",
        "    epilog='",
      }), i(4, "Text at the bottom of help"), t({
        "'",
        ")",
        "",
        "parser.add_argument(",
        "    '-f', '--foo',",
        "    nargs='?',",
        "    help='",
      }), i(5, "foo help"), t({
        "'",
        ")",
        "",
        "args = parser.parse_args()",
        "",
        "foo = args.foo",
      }),
    }),
    s("qreq", {
        t({
	    "import requests",
	    "",
	    "url = '",
	}), i(1, "https://example.com"), t({
	    "'",
	    "response = requests.get(url)",
	    "print(response.status_code)",
	    "print(response.text[:200])  # preview",
	}),
    }),
    s("qfind", {
	t({
	    "element = soup.find('",
	}), i(1, "div"), t({
	    "', { 'class': '",
        }), i(2, "classname"), t({
	"' })",
	"if element:",
	"    print(element.get_text(strip=True))",
        }),
    }),
    s("qselect", {
      t({
	"for item in soup.select('",
      }), i(1, "div.item > a"), t({
	"'):",
	"    print(item.get('href'))",
      }),
    }),
  })
end

return M

