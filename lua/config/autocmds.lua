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

