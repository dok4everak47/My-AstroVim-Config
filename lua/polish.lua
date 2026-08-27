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

-- Elm 缩进：统一 4 个空格；不使用 smartindent，交给 Elm indentexpr
local function setup_elm_indent()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "elm",
    callback = function(args)
      local buf = args.buf

      vim.bo[buf].tabstop = 4 -- 一个 Tab 显示为 4 个空格宽度
      vim.bo[buf].shiftwidth = 4 -- 回车换行/自动缩进使用 4 个空格
      vim.bo[buf].softtabstop = 4 -- 按 Tab 键插入 4 个空格
      vim.bo[buf].expandtab = true -- 使用空格而不是 Tab
      vim.bo[buf].smartindent = false -- Elm 使用内置 indentexpr，避免冲突
      vim.bo[buf].cindent = false
      vim.bo[buf].copyindent = true -- 空行/延续缩进尽量复制上一级缩进
      vim.bo[buf].preserveindent = true

      -- 防止 guess-indent 根据已有文件内容把缩进改成 2 空格
      vim.b[buf].guess_indent_skip = true
      if package.loaded["guess-indent"] then
        local config = require "guess-indent.config"
        if not vim.tbl_contains(config.filetype_exclude, "elm") then table.insert(config.filetype_exclude, "elm") end
      end
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
      vim.wo.wrap = true -- 自动换行
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

setup_elm_indent()

setup_language_specific_execution()

-- 设置 jk 为退出 Insert 模式
if vim.g.vscode then
  -- VSCode Neovim 最简单的映射
  vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
else
  -- 普通 Neovim 环境：退出并保存
  vim.keymap.set("i", "jk", "<Esc>:w<CR>", { noremap = true, silent = true })
end

-- 设置清晰的光标形状：Insert 模式下用竖线，加粗避免被遮挡
vim.opt.guicursor = "n-v-c:block,i:ver50,ci:ver50,ve:ver50,o:block,a:blinkon100"

-- 打开 Aerial 大纲视图（当前文件函数大纲，快速跳转）
vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<CR>", { desc = "Toggle Aerial outline" })
-- VS Code Cmd+Shift+O 风格搜索当前文件函数符号
vim.keymap.set("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "Go to symbol in current file (VS Code Cmd+Shift+O)" })

-- 原生 Treesitter 函数文本对象（if/af）
-- 不依赖 nvim-treesitter-textobjects，直接使用 vim.treesitter API
-- 适用于所有有 treesitter parser 的语言（Python、C++、Lua、TS 等）
local function setup_function_textobject()
  -- 从光标位置向上查找函数节点，返回 0-indexed 范围 (sr, sc, er, ec)
  local function get_function_range(outer)
    local node = vim.treesitter.get_node()
    if not node then return nil end

    while node do
      local t = node:type()
      -- 匹配各种语言的函数/方法/构造函数节点
      if t:match "function" or t:match "method" or t:match "constructor" then
        local sr, sc, er, ec = node:range()
        if not outer then
          -- 内部：尝试找到函数体 block
          for i = 0, node:named_child_count() - 1 do
            local child = node:named_child(i)
            if child then
              local ct = child:type()
              if ct:match "block" or ct:match "body" or ct == "suite" or ct == "compound_statement" then
                sr, sc, er, ec = child:range()
                break
              end
            end
          end
        end
        return sr, sc, er, ec
      end
      node = node:parent()
    end
    return nil
  end

  local function select(outer)
    local sr, sc, er, ec = get_function_range(outer)
    if not sr then
      vim.notify("No function at cursor", vim.log.levels.WARN)
      return
    end

    -- node:range() 返回 0-indexed (sr, sc, er, ec)，ec 为排他（不含）
    -- nvim_win_set_cursor 需要 1-indexed 行、0-indexed 列
    local start_row = sr + 1
    local start_col = sc

    local end_row, end_col
    if ec > 0 then
      end_row = er + 1
      end_col = ec - 1
    else
      -- ec == 0 表示范围结束在行首，最后一个字符在前一行末尾
      end_row = er
      end_col = math.max(#vim.fn.getline(er) - 1, 0)
    end

    -- 进入可视模式（如果当前不在）
    -- 在 operator-pending 模式下，进入可视模式后挂起的 operator 会作用于选区
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= "v" and mode ~= "V" and mode ~= "\x16" then
      vim.cmd "normal! v"
    end

    -- 设置选区起点 -> 跳到另一端 -> 设置选区终点
    vim.api.nvim_win_set_cursor(0, { start_row, start_col })
    vim.cmd "normal! o"
    vim.api.nvim_win_set_cursor(0, { end_row, end_col })
  end

  -- x = 可视模式, o = operator-pending 模式
  for _, m in ipairs { "x", "o" } do
    vim.keymap.set(m, "if", function() select(false) end, { desc = "Inside function (treesitter)" })
    vim.keymap.set(m, "af", function() select(true) end, { desc = "Around function (treesitter)" })
  end
end

setup_function_textobject()

