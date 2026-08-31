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
      -- Nix 格式化（2026-08-31：alejandra 已取代 nixpkgs-fmt）
      -- 系统 profile 已装 alejandra（nix-darwin packages.nix），无需 Mason
      null_ls.builtins.formatting.alejandra,
      -- TypeScript / JavaScript / web formatting (prettierd)
      -- ESLint diagnostics & code actions are provided by eslint-lsp,
      -- which is auto-configured by mason-lspconfig (not none-ls).
      null_ls.builtins.formatting.prettierd,
      -- Elm 格式化（2026-08-29：全局 elm 套件已移除，改从项目 devShell 找）
      -- 优先 .direnv/bin（direnv 激活），fallback 系统 profile
      null_ls.builtins.formatting.elm_format.with {
        extra_args = { "--elm-version=0.19" },
        command = function()
          local cwd = vim.fn.getcwd()
          local direnv_path = cwd .. "/.direnv/bin/elm-format"
          if vim.fn.filereadable(direnv_path) == 1 then return direnv_path end
          return vim.fn.exepath "elm-format"
        end,
      },
    })
  end,
}
