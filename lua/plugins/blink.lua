-- blink.cmp：补全体验对标 VS Code
--
-- 在 AstroNvim 默认之上补齐 VS Code 标志特性：
--   1. ghost_text  -- 接受前灰色 inline 预览候选文本（VS Code 标志性灰显）
--   2. Tab/CR=accept+分号  -- 接受补全后，若当前行像待结束的 Rust statement
--                             则自动在行末补 ';'（VS Code / IntelliJ 风格）
--   3. signature   -- blink 原生参数签名提示，输入 `(` 弹签名+高亮当前参数；
--                     开启后 AstroNvim 会自动禁用 astrolsp 的 lsp_signature，统一为 blink UI
--
-- AstroNvim 默认已具备（保留不动）：
--   - documentation.auto_show=true, delay=0   （悬浮文档自动显示，VS Code 同款）
--   - accept.auto_brackets=true               （接受后自动补 ()）
--   - menu.draw.treesitter={"lsp"}            （补全项 treesitter 高亮）
--   - fuzzy.implementation="prefer_rust"      （Rust 加速模糊匹配）

-- ── 补全后自动补分号（仅 rust）──────────────────────────────────────────
-- 启发式：行末字符是 字母/数字/下划线/闭括号/引号，且行首第一个词不在
-- 控制流或定义关键字集合 -> 在去掉尾部空白后的行末插入 ';'。
-- 宁可漏加（let/use/mod/const 用户手动补），绝不误加（if/fn/impl/match 等
-- 后跟 block 的语句一定不加），避免破坏语法。
local function maybe_add_semicolon()
  if vim.bo.filetype ~= "rust" then return end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if not line or line == "" then return end
  local trimmed = line:match "^%s*(.-)%s*$"
  if trimmed == "" then return end

  local last = trimmed:sub(-1)
  if last == ";" then return end -- 已有分号不重复

  -- 行末必须是"像 statement 结束"的字符：标识符/数字/闭括号/引号字面量
  local ok_end = last:match "[%w_]" ~= nil
    or last == ")"
    or last == "]"
    or last == '"'
    or last == "'"
  if not ok_end then return end

  -- 行首第一个词若在 控制流/定义/修饰 集合则不加（避免破坏 block 语句）
  local first = trimmed:match "^(%a[%w_]*)"
  local exclude = {
    ["if"] = true, ["else"] = true, ["while"] = true, ["for"] = true, ["in"] = true,
    loop = true, match = true, fn = true, impl = true, struct = true, enum = true,
    trait = true, type = true, pub = true, unsafe = true, async = true, extern = true,
    crate = true, where = true, move = true, as = true, dyn = true,
  }
  if first and exclude[first] then return end

  -- 在去掉尾部空白后的行末插入 ';'
  local stripped = line:gsub("%s*$", "")
  vim.api.nvim_buf_set_text(0, row - 1, #stripped, row - 1, #stripped, { ";" })
end

-- 接受补全项并在完成后（callback 时补全文本+auto_brackets 已就位）补分号。
-- 菜单不可见时返回 nil -> 落到 fallback chain（snippet_forward / 换行）。
local function accept_with_semicolon(cmp)
  if not cmp.is_menu_visible() then return end
  cmp.accept { callback = function() vim.schedule(maybe_add_semicolon) end }
  return true
end

---@type LazySpec
return {
  "Saghen/blink.cmp",
  opts = {
    -- Neutralize the default -3 penalty so snippets can compete with LSP keywords.
    snippets = { score_offset = 0 },

    sources = {
      -- Per-provider score offsets. Larger = higher in the menu.
      providers = {
        snippets = { score_offset = 1 },
        lsp = { score_offset = 0 },
        path = { score_offset = 2 },
        buffer = { score_offset = -3 },
      },
    },

    -- ── VS Code 风格按键 ──────────────────────────────────────────────
    -- 仅 override Tab / CR，其余按键（Ctrl-Space / 方向键 / Ctrl-N/P / Ctrl-U/D
    -- / Ctrl-E 等）沿用 AstroNvim 默认（lazy.nvim 对 opts.keymap 做 deep merge）。
    keymap = {
      -- Tab：菜单可见->接受补全+补分号；snippet 活跃->跳下一占位符；否则缩进。
      ["<Tab>"] = { accept_with_semicolon, "snippet_forward", "fallback" },
      -- S-Tab：snippet 反向跳占位符；否则上一项 / 反缩进。
      ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      -- CR（Enter）：菜单可见->接受补全+补分号；否则换行（VS Code 同款）。
      ["<CR>"] = { accept_with_semicolon, "fallback" },
    },

    completion = {
      list = {
        -- 预选最匹配项（高亮），但不自动插入文本 -- 输入字符不覆盖预选，
        -- Tab 才确认。完全对应 VS Code 的 preselect + 不 auto-insert 行为。
        selection = { preselect = true, auto_insert = false },
      },
      -- 灰色 inline 预览候选文本（VS Code 标志特性）。
      ghost_text = { enabled = true },
      menu = {
        draw = {
          components = {
            -- Append a small "~S" badge on snippet items so they're easy to spot.
            label = {
              text = function(ctx)
                if ctx.item.source_name == "Snippets" then
                  return ctx.label .. " ~S"
                end
                return ctx.label
              end,
            },
          },
        },
      },
    },

    -- blink 原生参数签名提示：输入 `(` 触发，浮窗显示函数签名 + 高亮当前参数。
    -- 开启后 AstroNvim blink spec 会自动设置 astrolsp.features.signature_help=false，
    -- 停用 lsp_signature.nvim，统一由 blink 提供签名 UI。
    signature = { enabled = true },
  },
}
