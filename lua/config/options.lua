-- LazyVim options (lua/config/options.lua)
-- 由 lazy.nvim 在 lazy.setup 之前自动加载
-- 原 AstroNvim astrocore.options 迁移到这里
-- 注意：colorscheme 不在本文件设置（见 lazy.lua spec：opts.colorscheme 或 colorscheme extra）

-- leader 键（AstroNvim 同款：空格；必须早于 lazy.setup，本文件正合适）
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Python LSP 选择：basedpyright（你 Mason 已装）而非默认 pyright
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

local opt = vim.opt

-- 行号（原 astrocore.options.opt）
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes"
opt.wrap = true
opt.spell = false

-- 缩进（默认 2 空格；C/C++/Elm 等按语言 autocmd 覆盖为 4）
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- 撤销/隐藏 buffer
opt.undofile = true
opt.hidden = true

-- 体验
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Cmd+S / Ctrl+S 保存（原 astrocore.mappings，三种模式）
for _, mode in ipairs({ "n", "i", "v" }) do
  vim.keymap.set(mode, "<D-s>", "<cmd>w<CR>", { desc = "Save" })
  vim.keymap.set(mode, "<C-s>", "<cmd>w<CR>", { desc = "Save" })
end
