-- Snacks terminal 修复: LazyVim v16 把 <C-l> 绑成"跳到右窗口" (term_nav "l"),
-- 导致 terminal 内 <C-l> 无法清屏。移除 nav_l, 保留 <C-h/j/k> 窗口导航。
return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      opts.terminal = opts.terminal or {}
      opts.terminal.win = opts.terminal.win or {}
      opts.terminal.win.keys = opts.terminal.win.keys or {}
      -- 去掉 <C-l> 的窗口导航绑定 (设 false 覆盖: nil 在 lazy merge 里等于没写)。
      -- snacks.win 遍历 keys 时跳过 falsy, 终端内 <C-l> 恢复为清屏 (form feed)
      opts.terminal.win.keys.nav_l = false
    end,
  },
}
