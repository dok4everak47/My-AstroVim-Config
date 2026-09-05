-- aerial 大纲增强: 函数名后显示循环数 (2026-09-05)
-- 用户需求: <leader>o (aerial 侧栏) 里每个函数显示它包含多少 for/while 循环。
-- 机制: aerial 扩展点 post_add_all_symbols(bufnr, items, ctx)。
-- ⚠️ 试过 treesitter 节点遍历计数 — 在该环境反复卡死/报错 (与 aerial 自身 parse 冲突),
--   放弃。改为轻量文本统计: 数函数区间 [lnum,end_lnum] 内以 for/while/loop 开头的
--   代码行 (rust 循环语句必从这三个关键字开始)。零 treesitter 依赖, 绝不卡。
--   ctx.lang: lsp backend = "rust-analyzer", treesitter backend = "rust", 两者都处理。
return {
  {
    "stevearc/aerial.nvim",
    opts = function(_, opts)
      opts.post_add_all_symbols = function(bufnr, items, ctx)
        if not (ctx and (ctx.lang == "rust" or ctx.lang == "rust-analyzer")) then
          return items
        end
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return items
        end
        local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
        if not ok or not lines then
          return items
        end
        for _, item in ipairs(items) do
          if item.kind == "Function" or item.kind == "Method" then
            local s, e = item.lnum or 0, item.end_lnum or item.lnum or 0
            local count = 0
            for l = s, math.min(e, #lines - 1) do
              local t = lines[l + 1] and lines[l + 1]:match("^%s*(%a+)") -- 0-based l → 1-based 行
              if t == "for" or t == "while" or t == "loop" then
                count = count + 1
              end
            end
            if count > 0 then
              item.name = string.format("%s (%d 循环)", item.name, count)
            end
          end
        end
        return items
      end
    end,
  },
}
