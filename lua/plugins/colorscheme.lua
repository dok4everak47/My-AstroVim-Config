-- Oxocarbon 主题 (2026-09-05, nyoom-engineering/oxocarbon.nvim)
-- IBM 碳黑风: dark 背景 (oxocarbon 默认; 也是 nyoom.nvim 用的主题)
-- oxocarbon 支持 vim.o.background = dark/light 切换 (默认 dark, 无需配置)
-- ⚠️ 不给 opts: oxocarbon 无 setup() 函数, LazyVim 遇 opts 会调 require().setup → nil 报错。
-- 纯 colorscheme 插件, lazy=false + LazyVim opts.colorscheme="oxocarbon" 即可自动加载。
-- 配色微调 (2026-09-05, 用户逐步选定):
--   变量 #3DDBD9 亮青 → 用户后改 #FF8000 橙
--   函数默认粉 #FF7EB6 → #FF0000 红
--   关键字默认蓝 #78A9FF → #7373B9 紫蓝
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Oxocarbon highlight tweaks (var/fn/keyword colors)",
  callback = function()
    if vim.g.colors_name ~= "oxocarbon" then
      return
    end
    -- 变量: 亮青 #3DDBD9 → 橙 #FF8000 (用户 2026-09-05 指定)
    vim.api.nvim_set_hl(0, "@variable", { fg = "#FF8000" })
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#FF8000" })
    vim.api.nvim_set_hl(0, "@variable.member", { fg = "#FF8000" })
    vim.api.nvim_set_hl(0, "@parameter", { fg = "#FF8000" })
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#FF8000" })
    -- 函数: 粉 → 红 #FF0000 (用户 2026-09-05 指定)
    vim.api.nvim_set_hl(0, "@function", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "@function.call", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "@function.method", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "@function.method.call", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "Function", { fg = "#FF0000" })
    -- 关键字: 蓝 → 紫蓝 #7373B9 (用户 2026-09-05 指定)
    vim.api.nvim_set_hl(0, "@keyword", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "@keyword.return", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "@keyword.exception", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "Keyword", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "Conditional", { fg = "#7373B9" })
    vim.api.nvim_set_hl(0, "Repeat", { fg = "#7373B9" })
    -- 布尔 false/true (@boolean → Boolean, 默认蓝 #78A9FF 与关键字撞) → 亮珊瑚红 #FF6B6B
    -- (区别于函数纯红 #FF0000; 2026-09-05 用户要求布尔也上色, 助手选色)
    vim.api.nvim_set_hl(0, "@boolean", { fg = "#FF6B6B" })
    vim.api.nvim_set_hl(0, "Boolean", { fg = "#FF6B6B" })
    -- 枚举变体/常量 (Redirect 等, @constant 默认紫 #BE95FF) → 暖黄 #E5C07B
    -- (oxocarbon 无黄系; 常量醒目又不与红/橙/紫蓝撞; 2026-09-05 助手选色)
    vim.api.nvim_set_hl(0, "@constant", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "@constant.builtin", { fg = "#E5C07B" })
  end,
})

return {
  {
    "nyoom-engineering/oxocarbon.nvim",
    name = "oxocarbon",
    lazy = false,
    priority = 1000,
  },
}
