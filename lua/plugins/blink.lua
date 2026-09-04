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

      -- Tab 自定义：snippet 占位导航 + “跳出右括号”
      -- 行为（2026-09-04，用户需求：LSP 展开的 func(${1}) 填完参数按 Tab 应跳到 ) 后）：
      --   - 在 snippet 内且有下一个占位符 → 正常跳下一占位（原 snippet_forward）
      --   - 在 snippet 内但无下一个占位（= 在最后一个参数占位上）→ 光标移到当前
      --     占位符节点 mark 的结束位置（天然=右括号后，正确处理嵌套括号），并结束 snippet
      --   - 不在 snippet 内 → 返回 false，让 fallback 走默认（缩进）
      -- 实测依据：LuaSnip 展开 func(${1:arg})，跳入占位符后 jumpable(1)=false（无下一占位），
      -- 光标卡在 ) 内；占位符节点 mark 的 pos_end() 返回 {end_row, end_col}（= ) 后）。
      opts.keymap["<Tab>"] = {
        function(cmp)
          -- 菜单可见时不劫持 Tab（菜单选候选不归我们管；这里只处理 snippet 导航）
          if cmp.is_menu_visible() then
            return false
          end
          local ls_ok, ls = pcall(require, "luasnip")
          if not ls_ok or not ls.in_snippet() then
            return false -- 不在 snippet → 交给 fallback（缩进）
          end
          if ls.jumpable(1) then
            -- 有下一占位：原 snippet_forward 行为
            vim.schedule(function()
              ls.jump(1)
            end)
            return true
          end
          -- 无下一占位（最后一个参数上）→ 光标移到占位符结束位置（右括号后）并结束会话
          vim.schedule(function()
            local ok_get, node = pcall(function()
              local session = require("luasnip.session")
              return session.current_nodes[vim.api.nvim_get_current_buf()]
            end)
            if ok_get and node and node.mark then
              local ok_end, pos = pcall(function() return node.mark:pos_end() end)
              if ok_end and pos and pos[1] ~= nil and pos[2] ~= nil then
                -- pos = { end_row, end_col }，行转 1-based，列直接（0-based）
                vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
              end
            end
            -- 结束 snippet 会话（光标已在括号外，安全）
            pcall(ls.unlink_current)
          end)
          return true
        end,
        "fallback",
      }
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
