-- blink.cmp 补全（LazyVim 默认补全就是 blink，这里覆盖为 VS Code 风格）
-- 原 AstroNvim lua/plugins/blink.lua 迁移
-- LazyVim blink extra 默认 preset="enter"；我们保持 VS Code 习惯：
--   - Tab/CR = 接受（accept 后 Rust 自动补分号见下）
--   - ghost_text 灰显预览（VS Code 标志）
--   - 签名提示开（blink signature；替代 lsp_signature）
--   - 补全后 Rust 自动补 ';'

-- Rust 补分号启发式（原 blink.lua maybe_add_semicolon，逐字保留）
local function maybe_add_semicolon()
  if vim.bo.filetype ~= "rust" then
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if not line or line == "" then
    return
  end
  local trimmed = line:match("^%s*(.-)%s*$")
  if trimmed == "" then
    return
  end
  local last = trimmed:sub(-1)
  if last == ";" then
    return
  end
  local ok_end = last:match("[%w_]") ~= nil
    or last == ")"
    or last == "]"
    or last == '"'
    or last == "'"
  if not ok_end then
    return
  end
  local first = trimmed:match("^(%a[%w_]*)")
  local exclude = {
    ["if"] = true, ["else"] = true, ["while"] = true, ["for"] = true, ["in"] = true,
    loop = true, match = true, fn = true, impl = true, struct = true, enum = true,
    trait = true, type = true, pub = true, unsafe = true, async = true, extern = true,
    crate = true, where = true, move = true, as = true, dyn = true,
  }
  if first and exclude[first] then
    return
  end
  local stripped = line:gsub("%s*$", "")
  vim.api.nvim_buf_set_text(0, row - 1, #stripped, row - 1, #stripped, { ";" })
end

local function accept_with_semicolon(cmp)
  if not cmp.is_menu_visible() then
    return
  end
  cmp.accept({ callback = function()
    vim.schedule(maybe_add_semicolon)
  end })
  return true
end

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
      -- Tab：菜单可见 -> 接受+补分号；snippet 活跃 -> 下一占位；否则缩进
      opts.keymap["<Tab>"] = { accept_with_semicolon, "snippet_forward", "fallback" }
      -- S-Tab：snippet 反向 / 上一项 / 反缩进
      opts.keymap["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" }
      -- CR：菜单可见 -> 接受+补分号；否则换行（VS Code 同款）
      opts.keymap["<CR>"] = { accept_with_semicolon, "fallback" }

      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      -- preselect 高亮但不自动插入（VS Code 行为）
      opts.completion.list.selection = { preselect = true, auto_insert = false }
      -- 灰显预览
      opts.completion.ghost_text = { enabled = true }

      -- 签名提示（blink 原生；LazyVim 默认 signature=false，开之）
      opts.signature = { enabled = true }
    end,
  },
}
