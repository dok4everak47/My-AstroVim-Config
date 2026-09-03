-- LazyVim keymaps (lua/config/keymaps.lua)
-- 原 AstroNvim polish.lua + astrocore.mappings 迁移到这里
-- 注：本文件由 LazyVim 在 VeryLazy 事件自动 require（见 lazyvim.config M.load）
-- 真实 GUI 打开时必触发；headless/后台无 UI 时不触发（正常现象）

local map = vim.keymap.set
-- LazyVim 的 <leader> 映射需走 Snacks.keymap.set（能正确处理 <leader> 前缀与 which-key 交互），
-- 裸 vim.keymap.set 注册 <leader> 映射会被 which-key 占位忽略。
local lmap = function(lhs, rhs, opts)
  Snacks.keymap.set("n", lhs, rhs, opts)
end


-- ── jk 退出插入模式（原 polish.lua：insert 模式 jk=Esc，普通 nvim 环境保存后退出）──
-- 注：VSCode Neovim 由 settings.json 的 vim.insertModeKeyBindingsNonRecursive 处理，
-- 此处只给真正的 nvim。
map("i", "jk", "<Esc>:w<CR>", { desc = "jk exit insert + save" })

-- ── 缓冲区切换（原 polish.lua setup_buffer_navigation + astrocore）──
lmap("<leader>bn", "<cmd>bn<CR>", { desc = "Next buffer" })
lmap("<leader>bp", "<cmd>bp<CR>", { desc = "Previous buffer" })
lmap("<leader>bb", "<cmd>e #<CR>", { desc = "Switch to last buffer" })
-- 数字 1-9 快速切缓冲
for i = 1, 9 do
  lmap("<leader>" .. i, function()
    vim.cmd("buffer " .. i)
  end, { desc = "Switch to buffer " .. i })
end
-- Alt+方向键切缓冲（非 leader，仍用 map）
map("n", "<A-Left>", "<cmd>bp<CR>", { desc = "Previous buffer" })
map("n", "<A-Right>", "<cmd>bn<CR>", { desc = "Next buffer" })
-- 当前窗口内切缓冲（跳过 nofile）
lmap("<leader>bh", function()
  vim.cmd("bp | if &bt == 'nofile' | bp | endif")
end, { desc = "Previous buffer in window" })
lmap("<leader>bl", function()
  vim.cmd("bn | if &bt == 'nofile' | bn | endif")
end, { desc = "Next buffer in window" })

-- ── 代码运行（python/cpp/c，原 polish.lua setup_language_specific_execution）──
-- 按文件类型运行当前文件（原 <leader>r 行为）；保留 :RunCode 亦可
local function run_current()
  vim.cmd("write")
  local ft = vim.bo.filetype
  if ft == "python" then
    vim.cmd("!python %")
  elseif ft == "cpp" then
    vim.cmd("!g++ -std=c++17 % -o %:r && ./%:r")
  elseif ft == "c" then
    vim.cmd("!gcc % -o %:r && ./%:r")
  else
    vim.cmd("!echo 'no run mapping for filetype: " .. (ft == "" and "none" or ft) .. "'")
  end
end

lmap("<leader>r", run_current, { desc = "Run current file" })

-- 终端内运行（垂直 split + terminal）
local function run_current_terminal()
  vim.cmd("write")
  local ft = vim.bo.filetype
  local cmd
  if ft == "python" then
    cmd = "python %"
  elseif ft == "cpp" then
    cmd = "g++ -std=c++17 % -o %:r && ./%:r"
  elseif ft == "c" then
    cmd = "gcc % -o %:r && ./%:r"
  end
  if cmd then
    vim.cmd("vsplit | terminal " .. cmd)
  else
    vim.notify("No run mapping for filetype: " .. ft, vim.log.levels.WARN)
  end
end

lmap("<leader>R", run_current_terminal, { desc = "Run current file in terminal" })

-- ── 终端开在当前文件目录（原 polish.lua setup_terminal_file_dir）──
-- LazyVim 默认用 snacks terminal。保持 <leader>tf/th（浮动/水平）。
lmap("<leader>tf", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  require("snacks").terminal.open(nil, { cwd = dir, float = true })
end, { desc = "Float terminal in file dir" })
lmap("<leader>th", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  require("snacks").terminal.open(nil, { cwd = dir, pos = "bottom" })
end, { desc = "Horizontal terminal in file dir" })

-- ── Aerial 大纲（原 polish.lua <leader>o；LazyVim aerial extra 默认 <leader>cs，保留 <leader>o）──
lmap("<leader>o", "<cmd>AerialToggle<cr>", { desc = "Toggle Aerial outline" })

-- ── VS Code 风格符号搜索（原 polish.lua <leader>fs）──
lmap("<leader>fs", function()
  Snacks.picker.lsp_symbols()
end, { desc = "Go to symbol in current file (VS Code Cmd+Shift+O)" })

-- ── 全项目符号搜索（VS Code Cmd+T 风格）──
-- LSP 支持 workspace/symbol（TS/rust 等）→ 用 LSP 精确符号；
-- 否则（nix/lua/elm/无 LSP）→ 降级为 grep 文本搜索（rg，跨文件，输入词即搜）。
-- nix 的 nil / lua 的 lua_ls 均无 workspaceSymbolProvider，降级让 <leader>fS 始终可用。
local function workspace_symbols_or_grep()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local supported = false
  for _, client in ipairs(clients) do
    if client.supports_method and client.supports_method("workspace/symbol") then
      supported = true
      break
    end
  end
  if supported then
    Snacks.picker.lsp_workspace_symbols()
  else
    -- 降级：grep 搜光标词（可编辑）。传当前词作为初始搜索，避免空搜。
    local word = vim.fn.expand("<cword>")
    if word == "" then
      Snacks.picker.grep()
    else
      Snacks.picker.grep(word)
    end
  end
end

lmap("<leader>fS", workspace_symbols_or_grep, { desc = "Workspace symbol search (LSP or grep fallback)" })

-- ── LSP 跳转（AstroNvim 用 gi，LazyVim 默认用 gI；补 gi 兼容肌肉记忆）──
map("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })

-- ── 智能缩进增量选择（原 polish.lua setup_incremental_selection；LazyVim treesitter 无此，重建）──
-- 用 nvim-treesitter-textobjects? 不，保持 C-space/bs 手动方案
do
  local api = vim.api
  local current_node = nil
  local function node_at_cursor()
    local row, col = unpack(api.nvim_win_get_cursor(0))
    return vim.treesitter.get_node({ bufnr = 0, row = row - 1, col = col })
  end
  local function select_node(node)
    if not node then
      return
    end
    current_node = node
    local sr, sc, er, ec = node:range()
    local mode = api.nvim_get_mode().mode
    if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
      vim.cmd("normal! v")
    end
    api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd("normal! o")
    local end_col
    if ec > 0 then
      end_col = ec - 1
    else
      local line = api.nvim_buf_get_lines(0, er, er + 1, false)[1]
      end_col = line and (#line - 1) or 0
    end
    api.nvim_win_set_cursor(0, { er + 1, math.max(end_col, 0) })
  end
  local function expand()
    local mode = api.nvim_get_mode().mode
    local visual = mode == "v" or mode == "V" or mode == "\22"
    if not visual or not current_node then
      local node = node_at_cursor()
      if node then
        select_node(node)
      end
      return
    end
    local parent = current_node:parent()
    if parent then
      select_node(parent)
    end
  end
  local function shrink()
    if not current_node then
      return
    end
    if current_node:named_child_count() > 0 then
      select_node(current_node:named_child(0))
    end
  end
  map({ "n", "x" }, "<C-space>", expand, { desc = "Treesitter: increment selection" })
  map("x", "<bs>", shrink, { desc = "Treesitter: decrement selection" })
end

-- ── 光标形状（原 polish.lua：insert 竖线）──
vim.opt.guicursor = "n-v-c:block,i:ver50,ci:ver50,ve:ver50,o:block,a:blinkon100"

-- ── 退出前停 LSP（原 astrocore autocmds VimLeavePre，治孤儿进程）──
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      pcall(vim.lsp.stop_client, client, true)
    end
  end,
  desc = "Stop all LSP clients on exit (fix orphan processes)",
})
