-- Material 主题 (对齐 VS Code 的 Material Theme Darker)
-- style=darker: 背景 #212121, 与 VS Code Material Theme Darker 完全一致
-- (默认 oceanic 是 #25363B 墨绿, 不是你要的黑)。
-- VS Code 里关键字(break/if/fn 等)是斜体 → Victor Mono 的 cursive italic 花体。
-- material.nvim 的 styles.keywords.italic=true 还原同样效果。
-- lazy=false: LazyVim 启动早期就会 vim.cmd.colorscheme("material")，
-- 插件必须已加载(rtp 就绪)否则失败回退 habamax。
-- 注意: contrast 必须是 table (boolean 会让 material 内部 pairs() 崩)。
vim.g.material_style = "darker"
return {
  {
    "marko-cerovac/material.nvim",
    name = "material",
    lazy = false,
    priority = 1000,
    opts = {
      contrast = {
        terminal = true,
        sidebars = true, -- darker 风格接近 Material Theme Darker
        floating_windows = false,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
      },
      styles = {
        comments = { italic = true },
        strings = {},
        keywords = { italic = true }, -- break/if/fn 等 → 花体 (Victor Mono cursive italic)
        functions = {},
        variables = {},
        operators = {},
        types = {},
      },
    },
  },
}
