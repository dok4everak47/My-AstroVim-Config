-- 当前函数内循环快速列表 (2026-09-05)
-- 需求: aerial 只显示符号(函数/结构体), for 循环不是符号不会出现。用户要
-- "看当前函数里有哪些循环, 点了能跳"。
-- 实现: vim.ui.select (snacks 接管 → 自动弹 picker 列表) — 最轻路径。
-- 键: <leader>ll — 查过 LazyVim 无此键。循环 = Loop List。
-- 计数: treesitter 小 query (for/while/loop 3 pattern) 不卡; 只扫当前函数区间。
return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ll",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          -- 非 rust 直接提示
          if vim.bo[bufnr].filetype ~= "rust" then
            vim.notify("仅支持 rust", vim.log.levels.INFO)
            return
          end
          local okp, parser = pcall(vim.treesitter.get_parser, bufnr)
          if not okp or not parser then
            vim.notify("treesitter 不可用", vim.log.levels.WARN)
            return
          end
          local qstr = [[(for_expression) @loop (while_expression) @loop (loop_expression) @loop]]
          local okq, query = pcall(vim.treesitter.query.parse, "rust", qstr)
          if not okq then
            vim.notify("query 解析失败", vim.log.levels.WARN)
            return
          end
          local trees = parser:parse()
          if not trees or #trees == 0 then
            return
          end
          -- nvim 0.12: parse() 返回 TSTree 列表, 元素需 :root() 拿根节点
          local root = trees[1]:root()
          -- 找光标所在函数
          local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
          local cur_fn
          local function find_fn(node)
            if cur_fn then
              return
            end
            local t = node:type()
            if t == "function_item" or t == "method_definition" then
              local sr, _, er, _ = node:range()
              if cur_row >= sr and cur_row <= er then
                cur_fn = node
                return
              end
            end
            for child in node:iter_children() do
              find_fn(child)
            end
          end
          find_fn(root)
          if not cur_fn then
            vim.notify("光标不在函数内", vim.log.levels.INFO)
            return
          end
          local fs, _, fe, _ = cur_fn:range()
          -- 收集函数内循环 (query 范围限定 fs..fe), 一次遍历
          local items = {}
          for id, node in query:iter_captures(root, bufnr, fs, fe) do
            if query.captures[id] == "loop" then
              local lr = (node:range()) -- start_row (首个返回值)
              local line = vim.api.nvim_buf_get_lines(bufnr, lr, lr + 1, false)[1] or ""
              items[#items + 1] = {
                text = string.format("%d:%s", lr + 1, vim.trim(line)),
                row = lr,
              }
            end
          end
          if #items == 0 then
            vim.notify("当前函数内没有循环", vim.log.levels.INFO)
            return
          end
          -- 列表选跳转 (vim.ui.select → snacks picker)
          local texts = vim.tbl_map(function(it)
            return it.text
          end, items)
          vim.ui.select(texts, {
            prompt = "循环 (" .. #items .. ") — 回车跳转",
          }, function(choice, idx)
            if choice and idx and items[idx] then
              vim.api.nvim_win_set_cursor(0, { items[idx].row + 1, 0 })
            end
          end)
        end,
        desc = "List loops in current function",
      },
    },
  },
}
