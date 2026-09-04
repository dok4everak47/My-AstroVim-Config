-- blink.cmp 补全（LazyVim 默认补全就是 blink，这里覆盖为 VS Code 风格）
-- 原 AstroNvim lua/plugins/blink.lua 迁移
-- LazyVim blink extra 默认 preset="enter"；我们保持 VS Code 习惯：
--   - Tab 只做 snippet 占位导航
--   - ghost_text 灰显预览（VS Code 标志）
--   - 签名提示开（blink signature；替代 lsp_signature）
--   - 2026-09-04: 取消补全后 Rust 自动补 ';'（accept_with_semicolon 已移除）

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- LuaSnip 引擎（extra 已注入 LuaSnip+friendly-snippets+vscode loader；
      -- 覆盖内置 vim.snippet——0.12.4 上跳 $0 占位会 invalid-extmark 崩溃）
      opts.snippets = opts.snippets or {}
      opts.snippets.preset = "luasnip"
      if opts.snippets.preset == "luasnip" then
        opts.snippets.expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end
      end

      -- 默认 sources 基础上微调（保留 lsp/path/snippets/buffer 顺序）
      opts.sources = opts.sources or {}
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        snippets = { score_offset = 1 },
        lsp = { score_offset = 0 },
        path = { score_offset = 2 },
        buffer = { score_offset = -3 },
      })

      -- VS Code 风格按键
      opts.keymap = opts.keymap or {}
      -- Tab：只做 snippet 占位导航（有活跃 snippet 跳下一占位；否则 fallback 缩进）。
      -- 不绑 select_next：菜单里选候选统一用 ↑/↓ 或 Enter 确定（VS Code 里 Tab 选候选
      -- 用户不想要，2026-09-04）。
      opts.keymap["<Tab>"] = { "snippet_forward", "fallback" }
      -- S-Tab：snippet 反向 / 反缩进
      opts.keymap["<S-Tab>"] = { "snippet_backward", "fallback" }
      -- CR：菜单可见 -> 接受补全；否则换行（VS Code 同款：Enter 确定）。
      -- 2026-09-04 移除 accept_with_semicolon：补全后不再自动补 ';'（用户不想要）。
      opts.keymap["<CR>"] = { "accept", "fallback" }

      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      -- preselect 高亮但不自动插入（VS Code 行为）
      opts.completion.list.selection = { preselect = true, auto_insert = false }
      -- 灰显预览
      -- ⚠️ 2026-09-04: ghost_text 与 LuaSnip 占位跳转冲突 (extmark 竞争,
      -- 日志 mark.lua:82/35/136 崩溃 + for snippet Tab 跳转插入幽灵文本)。
      -- 暂关, 观察 Tab 跳转是否恢复稳定。
      -- opts.completion.ghost_text = { enabled = true }

      -- 签名提示（blink 原生；LazyVim 默认 signature=false，开之）
      opts.signature = opts.signature or {}
      opts.signature.enabled = true
      opts.signature.window = opts.signature.window or {}
      -- 优先在光标下方弹出（默认 {'n','s'} 会向上盖住代码）
      opts.signature.window.direction_priority = { "s", "n" }
      -- 限制高度，避免大面积遮挡
      opts.signature.window.max_height = 8
    end,
  },
}
