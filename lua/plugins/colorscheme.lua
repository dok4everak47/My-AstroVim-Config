-- Oxocarbon 主题 (2026-09-05, nyoom-engineering/oxocarbon.nvim)
-- IBM 碳黑风: dark 背景 (oxocarbon 默认; 也是 nyoom.nvim 用的主题)
-- oxocarbon 支持 vim.o.background = dark/light 切换 (默认 dark, 无需配置)
-- ⚠️ 不给 opts: oxocarbon 无 setup() 函数, LazyVim 遇 opts 会调 require().setup → nil 报错。
-- 纯 colorscheme 插件, lazy=false + LazyVim opts.colorscheme="oxocarbon" 即可自动加载。
-- 配色微调: oxocarbon 变量默认 #D0D0D0(同前景, 无辨识度) → 亮青 #3DDBD9
--   (与函数粉 #FF7EB6 / 关键字蓝 #78A9FF / 字符串紫 #BE95FF / 数字浅蓝 #82CFFF 均区分,
--    oxocarbon accent 青系, 暗底舒适; 2026-09-05)
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Oxocarbon variable highlight tweak",
  callback = function()
    if vim.g.colors_name ~= "oxocarbon" then
      return
    end
    vim.api.nvim_set_hl(0, "@variable", { fg = "#3DDBD9" })
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#3DDBD9" })
    vim.api.nvim_set_hl(0, "@variable.member", { fg = "#3DDBD9" })
    vim.api.nvim_set_hl(0, "@parameter", { fg = "#3DDBD9" })
    vim.api.nvim_set_hl(0, "Identifier", { fg = "#3DDBD9" })
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
