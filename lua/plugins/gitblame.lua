-- git-blame.nvim: 每行行尾显示修改作者+日期 (GitLens 风格, 2026-09-05)
-- gitsigns 只给光标行 blame (空格 ghb); 这个是所有行行尾常驻 virtual text。
-- 日期精简为 YYYY-MM-DD; 模板: 作者 • 日期 (summary 太长, 光标行 blame 空格 ghb 看全文)。
return {
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = true,
      message_template = " <author> • <date>",
      date_format = "%Y-%m-%d",
      virtual_text_column = 1,
    },
  },
}
