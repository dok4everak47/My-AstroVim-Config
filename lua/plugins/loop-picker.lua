-- 文件内循环树形列表 (2026-09-05, v3 按函数分组树)
-- 需求演进: ① 当前函数循环列表 → ② 带预览跟随 → ③ 整个文件所有循环, 按 fn 分组
--   树形: 函数可展开/折叠 (Tab / l / h), 循环行缩进在函数下, 可跳转 + 预览跟随。
-- 实现: 全部用 treesitter 收集 (nvim 0.12 API: tree:root())。不用 snacks 的
--   explorer 树机制 (太重), 自己维护折叠状态 + 自定义 format 画树线。
-- 结构: 函数行 item {fn=真, open=bool}; 循环行 item {fn=假, parent 函数名}
--   折叠: Tab/l 展开, h 折叠; 循环行回车跳转, 函数行回车折叠切换。
return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ll",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype ~= "rust" then
            vim.notify("仅支持 rust", vim.log.levels.INFO)
            return
          end
          local file = vim.api.nvim_buf_get_name(bufnr)
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
          local root = trees[1]:root()

          -- 收集: 每个函数 (按源码顺序) + 其循环
          local funcs = {} ---@type {name:string,row:number,loops:{row:number,text:string}[]}[]
          local function walk_fn(node)
            local t = node:type()
            if t == "function_item" or t == "method_definition" then
              local sr, _, er, _ = node:range()
              local name = ""
              for child in node:iter_children() do
                if child:type() == "identifier" then
                  name = vim.treesitter.get_node_text(child, bufnr)
                  break
                end
              end
              funcs[#funcs + 1] = { name = name, row = sr, loops = {}, node = node }
              return -- 不深入嵌套函数 (rust 无嵌套 fn)
            end
            for child in node:iter_children() do
              walk_fn(child)
            end
          end
          walk_fn(root)

          -- 每个函数收集循环 (query 限定函数区间)
          for _, fn in ipairs(funcs) do
            local fs, _, fe, _ = fn.node:range()
            for id, node in query:iter_captures(root, bufnr, fs, fe) do
              if query.captures[id] == "loop" then
                local lr = (node:range())
                local line = vim.api.nvim_buf_get_lines(bufnr, lr, lr + 1, false)[1] or ""
                fn.loops[#fn.loops + 1] = { row = lr, text = vim.trim(line) }
              end
            end
          end
          -- 丢弃无循环函数
          local has = {}
          for _, fn in ipairs(funcs) do
            if #fn.loops > 0 then
              has[#has + 1] = fn
            end
          end
          if #has == 0 then
            vim.notify("文件中没有含循环的函数", vim.log.levels.INFO)
            return
          end

          -- 折叠状态
          local open = {} ---@type table<number,boolean> 函数行号 → 展开?
          for _, fn in ipairs(has) do
            open[fn.row] = true -- 默认全展开
          end

          -- 生成当前可见 items
          local function build_items()
            local items = {}
            local source_id = 1
            for _, fn in ipairs(has) do
              local is_open = open[fn.row]
              items[#items + 1] = {
                source_id = source_id,
                kind = "fn",
                fn_row = fn.row,
                fn_name = fn.name,
                file = file, -- 函数行也有文件, 预览可跟随到函数定义处
                pos = { fn.row + 1, 0 },
                text = fn.name .. " (" .. #fn.loops .. " 循环)",
                loops = fn.loops,
              }
              if is_open then
                for _, lp in ipairs(fn.loops) do
                  items[#items + 1] = {
                    source_id = source_id,
                    kind = "loop",
                    fn_row = fn.row,
                    file = file,
                    pos = { lp.row + 1, 0 },
                    text = string.format("%d:%s", lp.row + 1, lp.text),
                    loop_text = lp.text,
                  }
                end
              end
            end
            return items
          end

          local state = { open = open, funcs = has }

          require("snacks").picker.pick({
            title = "Loops by function",
            prompt = "Loops: Enter jump / Tab fold >",
            finder = function()
              return build_items()
            end,
            format = function(item)
              local ret = {}
              if item.kind == "fn" then
                local icon = state.open[item.fn_row] and "▾ " or "▸ "
                ret[#ret + 1] = { icon, "SnacksPickerDirectory" }
                ret[#ret + 1] = { item.fn_name, "SnacksPickerDirectory" }
                ret[#ret + 1] = { " (" .. #item.loops .. " 循环)", "Comment" }
              else
                ret[#ret + 1] = { "  │ ", "SnacksPickerTree" }
                -- 行号 + 代码
                local lno, code = item.text:match("^(%d+):(.*)$")
                ret[#ret + 1] = { lno .. ":", "SnacksPickerRow" }
                ret[#ret + 1] = { " " .. code, "SnacksPickerFile" }
              end
              return ret
            end,
            preview = "file",
            actions = {
              -- Tab 默认是 select_and_next(多选标记); 覆盖它: 折叠/展开当前函数
              select_and_next = function(picker)
                local item = picker:current()
                -- fn 行或 loop 行都作用到所属函数
                if item and (item.kind == "fn" or item.kind == "loop") then
                  state.open[item.fn_row] = not state.open[item.fn_row]
                  picker:refresh()
                end
              end,
              fn_toggle = function(picker)
                local item = picker:current()
                if item and item.kind == "fn" then
                  state.open[item.fn_row] = not state.open[item.fn_row]
                  picker:refresh()
                end
              end,
              fn_collapse = function(picker)
                local item = picker:current()
                if item and item.kind == "fn" then
                  state.open[item.fn_row] = false
                  picker:refresh()
                end
              end,
              -- 回车: 函数行折叠切换, 循环行跳转
              confirm = function(picker)
                local item = picker:current()
                if item.kind == "fn" then
                  state.open[item.fn_row] = not state.open[item.fn_row]
                  picker:refresh()
                else
                  picker:close()
                  vim.api.nvim_win_set_cursor(0, item.pos)
                end
              end,
            },
            win = {
              input = {
                keys = {
                  ["<Tab>"] = { "fn_toggle", mode = { "i", "n" } },
                },
              },
              list = {
                keys = {
                  ["<Tab>"] = { "fn_toggle", mode = { "n", "i", "x" } },
                  ["l"] = { "fn_toggle", mode = { "n", "x" } },
                  ["h"] = { "fn_collapse", mode = { "n", "x" } },
                },
              },
            },
          })
        end,
        desc = "List loops in current file (by function)",
      },
    },
  },
}
