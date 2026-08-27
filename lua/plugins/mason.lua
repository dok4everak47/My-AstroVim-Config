-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "vtsls",
        "eslint-lsp",
        "json-lsp",
        "css-lsp",
        "html-lsp",

        -- install formatters
        "stylua",
        "prettierd",
        "prettier",

        -- install linters
        "eslint_d",

        -- install debuggers
        "debugpy",
        "js-debug-adapter",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },
}
