-- Bootstrap lazy.nvim + LazyVim (lua/config/lazy.lua)
-- 结构对齐 LazyVim starter：init.lua 只 require 本文件
-- 本文件在 lazy.setup 前配置好 rtp，随后加载 LazyVim 及所有 spec。
-- lua/config/options.lua / keymaps.lua / autocmds.lua 由 lazy.nvim 自动加载
-- （options 在 setup 前，keymaps/autocmds 在 VeryLazy）

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit...", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- 引入 LazyVim 及其默认插件集；colorscheme 用你原本的 catppuccin
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "catppuccin",
      },
    },
    -- 可选 extras（对齐原 AstroNvim 功能面）
    { import = "lazyvim.plugins.extras.editor.aerial" }, -- Aerial 大纲
    { import = "lazyvim.plugins.extras.editor.neo-tree" }, -- neo-tree 文件树
    { import = "lazyvim.plugins.extras.coding.luasnip" }, -- LuaSnip 引擎 + friendly-snippets（blink 后端）
    { import = "lazyvim.plugins.extras.lang.elm" }, -- Elm (LSP/treesitter/format)
    { import = "lazyvim.plugins.extras.lang.nix" }, -- Nix (nil_ls/treesitter)
    { import = "lazyvim.plugins.extras.lang.python" }, -- Python (basedpyright/ruff/venv)
    { import = "lazyvim.plugins.extras.lang.clangd" }, -- C/C++ (clangd + clangd_extensions)
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- TS/JS (vtsls)
    { import = "lazyvim.plugins.extras.lang.rust" }, -- Rust (rustaceanvim + rust-analyzer, devShell 提供)
    { import = "lazyvim.plugins.extras.dap.core" }, -- 调试核心
    -- 本地用户插件
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- 自定义插件默认立即加载（starter 同款；LazyVim 插件仍懒加载）
    version = false,
  },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = false }, -- 关自动更新检查（保持可手动 :Lazy update）
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
})
