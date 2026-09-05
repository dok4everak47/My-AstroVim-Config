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
      -- 行为（2026-09-04）：在 snippet 内按 Tab：
      --   1) 有下一占位符 → ls.jump(1) 正常跳
      --   2) jump 后当前节点是 exitNode(type=8, LuaSnip 隐含的 "snippet 结束" 节点，
      --      位于右括号后) → 光标移到该节点 mark 结束位（= 跳出括号），并结束会话
      --   3) 不在 snippet → fallback（缩进）
      -- 实测依据（2026-09-04）：Some($1) 空占位展开后 jumpable(1)=true，但 jump(1) 只把
      -- current_nodes 移到隐含 exitNode，LuaSnip 不负责把光标移到 exit 位置 → 光标卡在 )
      -- 内。必须检测 exitNode 后手动补移光标。
      opts.keymap["<Tab>"] = {
        function(cmp)
          local ls_ok, ls = pcall(require, "luasnip")
          local sess_ok, session = pcall(require, "luasnip.session")
          if not (ls_ok and sess_ok) then
            return false
          end
          local buf = vim.api.nvim_get_current_buf()
          local has_session = session.current_nodes[buf] ~= nil
          local menu_visible = cmp.is_menu_visible()
          -- 策略：菜单可见 + 已有会话 → 跳转（会话优先）；菜单可见 + 无会话 → 不劫持（正常补全选择）
          if menu_visible and not has_session then
            return false -- 补全菜单正常开着，无 snippet 会话 → 交给 fallback
          end

          if not has_session then
            return false -- 无会话 → fallback（缩进）
          end

          vim.schedule(function()
            local jumped = false
            if ls.jumpable(1) then
              ls.jump(1)
              jumped = true
            end
            if not ls.in_snippet() then
              return -- 会话已自然结束
            end
            local node = session.current_nodes[buf]
            if not node then
              return
            end
            if node.type == 8 or not jumped then
              local okp, pos = pcall(function() return node.mark:pos_end() end)
              if okp and pos and pos[1] ~= nil and pos[2] ~= nil then
                vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
              end
              pcall(ls.unlink_current)
            end
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

      -- 强制 Rust fuzzy 实现（2026-09-05）
      -- 现象：frecency（按使用频率排序）完全无效。根因：blink 默认 prefer_rust_with_warning，
      -- 启动时 ensure_downloaded 的异步决策未切到 rust（dylib 能 require、checksum 匹配，
      -- 但 implementation_type 停在 lua），而 frecency 只在 rust 实现生效。
      -- 修复：显式 prefer_rust，dylib 已就绪（target/release/libblink_cmp_fuzzy.dylib，
      -- checksum 已验证匹配），加载失败会报错而不是静默降级。
      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.implementation = "prefer_rust"
    end,
  },
}
