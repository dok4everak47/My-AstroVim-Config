-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- 按文件类型设置执行快捷键
local function setup_language_specific_execution()
  -- Python 专用快捷键
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      -- Python 执行映射
      vim.keymap.set("n", "<leader>r", "<cmd>w<CR><cmd>!python %<CR>", { buffer = true, desc = "Run Python file" })
      vim.keymap.set(
        "n",
        "<leader>R",
        "<cmd>vsplit | terminal python %<CR>",
        { buffer = true, desc = "Run Python in terminal" }
      )
    end,
  })

  -- C++ 专用快捷键
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
      -- C++ 执行映射
      vim.keymap.set(
        "n",
        "<leader>r",
        "<cmd>w<CR><cmd>!g++ -std=c++17 % -o %:r && ./%:r<CR>",
        { buffer = true, desc = "Compile and run C++ file" }
      )
      vim.keymap.set(
        "n",
        "<leader>R",
        "<cmd>vsplit | terminal g++ -std=c++17 % -o %:r && ./%:r<CR>",
        { buffer = true, desc = "Compile and run C++ in terminal" }
      )
      vim.keymap.set(
        "n",
        "<leader>c",
        "<cmd>!g++ -std=c++17 % -o %:r<CR>",
        { buffer = true, desc = "Compile C++ file" }
      )
    end,
  })

  -- C 专用快捷键
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
      vim.keymap.set(
        "n",
        "<leader>r",
        "<cmd>w<CR><cmd>!gcc % -o %:r && ./%:r<CR>",
        { buffer = true, desc = "Compile and run C file" }
      )
    end,
  })
end

-- 在 polish.lua 中添加 C++ 缩进配置
local function setup_cpp_indent()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cpp", "c", "h", "hpp", "hxx", "cc", "cxx" },
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      -- 设置 tab 为 4 个空格
      vim.bo[buf].tabstop = 4 -- 一个 tab 显示为 4 个空格宽度
      vim.bo[buf].shiftwidth = 4 -- 自动缩进使用 4 个空格
      vim.bo[buf].softtabstop = 4 -- 按 Tab 键插入 4 个空格
      vim.bo[buf].expandtab = true -- 将 tab 转换为空格
      vim.bo[buf].smartindent = true -- 智能缩进

      -- 其他代码风格设置
      vim.bo[buf].textwidth = 80 -- 行宽限制
      vim.wo.wrap = false -- 不自动换行
    end,
  })
end

-- 在 polish.lua 中添加这个配置
local function setup_cpp_autosemicolon()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cpp", "c" },
    callback = function()
      vim.keymap.set("i", "<CR>", function()
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-y>", true, true, true), "n")
          vim.defer_fn(function()
            local line = vim.fn.getline "."
            -- 简单的分号添加逻辑
            if not line:match "[};]%s*$" and not line:match "^%s*#" then vim.cmd "normal! A;" end
          end, 50)
          return ""
        else
          return "<CR>"
        end
      end, { buffer = true, expr = true })
    end,
  })
end

setup_cpp_autosemicolon()

setup_cpp_indent()

setup_language_specific_execution()

-- 设置 jk 为退出 Insert 模式
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
