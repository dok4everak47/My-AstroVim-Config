-- render-markdown.nvim：nvim 内 markdown 美化渲染（2026-09-04，用户选定方案 B）
-- 标题/代码块/列表/引用在 buffer 内直接渲染样式；光标所在块还原为可编辑文本。
-- 开关：<leader>um（Snacks.toggle）
-- 注意：只加本插件；不 import LazyVim lang.markdown extra（那会连带
-- markdown-preview.nvim[Node build] + marksman LSP，不符合轻量原则）。
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 覆盖全局 defaults.lazy=false：打开 markdown 类文件才加载
    lazy = true,
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {}, -- 不依赖 mini.icons / nvim-web-devicons
      },
      checkbox = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
}
