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

-- 使用当前文件所在目录打开终端（支持浮动和水平）
local function setup_terminal_file_dir()
  -- 通用的终端打开函数
  local function open_terminal_in_file_dir(direction)
    local current_file = vim.fn.expand "%:p"
    local file_dir = vim.fn.fnamemodify(current_file, ":h")

    -- 如果当前没有文件，使用工作目录
    if current_file == "" then file_dir = vim.fn.getcwd() end

    print("Opening " .. direction .. " terminal in file directory:", file_dir)

    require("toggleterm").toggle(1, 20, file_dir, direction)

    -- 延迟发送 fish 命令
    vim.defer_fn(function()
      if vim.b.terminal_job_id then
        vim.fn.chansend(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(file_dir) .. "\n")
        vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
        -- vim.fn.chansend(vim.b.terminal_job_id, "echo 'File: " .. vim.fn.expand('%:t') .. "'\n")
      end
    end, 500)
  end

  -- 浮动终端
  vim.keymap.set(
    "n",
    "<leader>tf",
    function() open_terminal_in_file_dir "float" end,
    { desc = "Float terminal in file directory" }
  )

  -- 水平终端
  vim.keymap.set(
    "n",
    "<leader>th",
    function() open_terminal_in_file_dir "horizontal" end,
    { desc = "Horizontal terminal in file directory" }
  )
end

-- 针对 fish shell 的配置
-- local function setup_fish_toggleterm()
--   vim.keymap.set("n", "<leader>tf", function()
--     local current_dir = vim.fn.getcwd()
--
--     require("toggleterm").toggle(1, 100, current_dir, "float")
--
--     -- 延迟发送 fish 的 cd 命令
--     vim.defer_fn(function()
--       if vim.b.terminal_job_id then
--         -- fish shell 的 cd 命令
--         vim.fn.chansend(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(current_dir) .. "\n")
--         vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
--       end
--     end, 200)
--   end, { desc = "Float terminal in current dir (fish)" })
-- end
--
-- setup_fish_toggleterm()

-- 增强缓冲区切换配置
local function setup_buffer_navigation()
  -- 基本缓冲区操作
  vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>", { desc = "Previous buffer" })
  vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
  vim.keymap.set("n", "<leader>bD", "<cmd>bd!<CR>", { desc = "Force delete buffer" })

  -- 快速切换到最近使用的缓冲区
  vim.keymap.set("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to last buffer" })

  -- 使用数字键快速切换缓冲区 (1-9)
  for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. i, function() vim.cmd("buffer " .. i) end, { desc = "Switch to buffer " .. i })
  end

  -- Alt + 方向键切换缓冲区
  vim.keymap.set("n", "<A-Right>", "<cmd>bn<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<A-Left>", "<cmd>bp<CR>", { desc = "Previous buffer" })

  -- 只在当前窗口的缓冲区中切换（忽略其他窗口的缓冲区）
  vim.keymap.set(
    "n",
    "<leader>bh",
    function() vim.cmd "bp | if &bt == 'nofile' | bp | endif" end,
    { desc = "Previous buffer in window" }
  )

  vim.keymap.set(
    "n",
    "<leader>bl",
    function() vim.cmd "bn | if &bt == 'nofile' | bn | endif" end,
    { desc = "Next buffer in window" }
  )
end

setup_buffer_navigation()

setup_terminal_file_dir()

setup_cpp_autosemicolon()

setup_cpp_indent()

setup_language_specific_execution()

-- 设置 jk 为退出 Insert 模式
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
