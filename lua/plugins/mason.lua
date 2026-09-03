-- mason 自动安装（原 AstroNvim lua/plugins/mason.lua 迁移）
-- LazyVim 默认已有 mason + mason-lspconfig；这里只扩展 ensure_installed。
-- 注意：你本机 mason/packages 已装 clangd/vtsls/lua_ls/基于 pyright 等，
-- ensure_installed 用于补装缺失项；已装的不重复下载。
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- 已在本机 mason 安装的，无需重复列出（lazy 会自动探测），
        -- 但为了「新机器也能一键装齐」，这里列出核心工具（幂等）：
        "lua-language-server",
        "stylua",
        "vtsls",
        "eslint-lsp",
        "json-lsp",
        "css-lsp",
        "html-lsp",
        "prettierd",
        "prettier",
        "eslint_d",
        "debugpy",
        "js-debug-adapter",
        "tree-sitter-cli",
        -- Python（basedpyright 已在 mason，这里幂等）
        "basedpyright",
        "ruff",
        "black",
        "isort",
        -- C/C++
        "clangd",
        "codelldb",
        -- Elm 的 elm-format 在 devShell（nix），不走 mason；nil 在 nix-darwin
      },
    },
  },
}
