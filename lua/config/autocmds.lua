-- LazyVim autocmds (lua/config/autocmds.lua)
-- 原 polish.lua 的 FileType 级 autocmd 尽量移到这里（无插件依赖的），
-- 需要具体插件（conform/treesitter）的放对应 plugin spec。

-- C++/C 缩进 4 空格 + textwidth（原 polish.lua setup_cpp_indent）
-- 注意 LazyVim 默认 tabstop=2；这里对 C/C++ 覆盖为 4
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp", "hxx", "cc", "cxx" },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].tabstop = 4
    vim.bo[buf].shiftwidth = 4
    vim.bo[buf].softtabstop = 4
    vim.bo[buf].expandtab = true
    vim.bo[buf].textwidth = 80
  end,
  desc = "C/C++ 4-space indent",
})

-- Elm 缩进 4 空格（原 polish.lua setup_elm_indent；Elm 用 treesitter indentexpr）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "elm",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].tabstop = 4
    vim.bo[buf].shiftwidth = 4
    vim.bo[buf].softtabstop = 4
    vim.bo[buf].expandtab = true
    vim.bo[buf].smartindent = false
    vim.bo[buf].cindent = false
    vim.bo[buf].copyindent = true
    vim.bo[buf].preserveindent = true
    vim.b[buf].guess_indent_skip = true
  end,
  desc = "Elm 4-space indent",
})

-- C/C++ 自动分号（原 polish.lua setup_cpp_autosemicolon；保留，仅 cpp/c）
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c" },
  callback = function()
    local map = vim.keymap.set
    map("i", "<CR>", function()
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-y>", true, true, true), "n")
        vim.defer_fn(function()
          local line = vim.fn.getline(".")
          if not line:match("[};]%s*$") and not line:match("^%s*#") then
            vim.cmd("normal! A;")
          end
        end, 50)
        return ""
      else
        return "<CR>"
      end
    end, { buffer = true, expr = true })
  end,
  desc = "C/C++ auto-semicolon",
})

-- LSP 附加：codelens 刷新（原 astrolsp autocmds 迁移；由 astrolsp 处理，
-- LazyVim 在 codelens.enabled=true 时自动刷新。此文件不再重复）

-- 打开代码文件默认全部折叠 (2026-09-05)
-- 用户需求: 打开文件不想每次手动按 zM, 希望默认全折叠看结构。
-- 用 BufReadPost + defer: 等文件加载/LSP 折叠就绪后再 zM (expr foldexpr 需就绪)。
-- 折衷: 进入文件即全折叠, 想展开按 zR/zo。只对真实文件 (可读 buffer), 排除 nofile。
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- 排除无文件名/特殊 buffer
    if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "" then
      return
    end
    -- 延迟到折叠就绪 (LSP/treesitter foldexpr 需 attach 后)
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      pcall(vim.cmd, "silent! normal! zM")
    end, 150)
  end,
  desc = "Fold all by default when opening code files",
})

