-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- TypeScript / JavaScript / web formatting (prettierd)
      -- ESLint diagnostics & code actions are provided by eslint-lsp,
      -- which is auto-configured by mason-lspconfig (not none-ls).
      null_ls.builtins.formatting.prettierd,
      -- Elm 格式化（nix-darwin 声明安装的 elm-format 0.8.8）
      null_ls.builtins.formatting.elm_format.with {
        extra_args = { "--elm-version=0.19" },
      },
    })
  end,
}
