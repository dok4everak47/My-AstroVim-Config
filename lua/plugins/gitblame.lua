-- git-blame.nvim: 每行行尾显示修改作者+日期 (GitLens 风格, 2026-09-05)
-- gitsigns 只给光标行 blame (空格 ghb); 这个是所有行行尾常驻 virtual text。
-- 日期精简为 YYYY-MM-DD; 模板: 作者 • 日期 (summary 太长, 光标行 blame 空格 ghb 看全文)。
-- 颜色: 默认 Comment (#525252 太暗) → 自定义 GitBlameHL = #FF60AF 亮粉 (2026-09-05 用户选定)。
-- 注意: highlight_group 需在插件加载时已存在的 group, 故在 plugins 加载早期用 autocmd 兜底定义。
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Define GitBlameHL highlight (survives colorscheme reloads)",
  callback = function()
    vim.api.nvim_set_hl(0, "GitBlameHL", { fg = "#FF60AF", default = true })
  end,
})
-- 立即定义一次(若当前 colorscheme 已加载)
pcall(vim.api.nvim_set_hl, 0, "GitBlameHL", { fg = "#FF60AF", default = true })

return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = true,
      message_template = " <author> • <date>",
      date_format = "%Y-%m-%d",
      virtual_text_column = 1,
      highlight_group = "GitBlameHL",
    },
  },
}
