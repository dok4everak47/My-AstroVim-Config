-- treesitter-textobjects 扩展: 循环跳转 (2026-09-05)
-- LazyVim 默认 move 键只有 function (]f/[f) / class (]c/[c) / parameter (]a/[a)。
-- 用户要快速定位 for/while 循环 → 加 ]l/[l (loop.outer, rust 等 query 已支持)。
-- opts 函数链深合并: 只加自己的键, 不覆盖 LazyVim 已有的 ]f/]c/]a 等。
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      opts.move = opts.move or {}
      opts.move.keys = opts.move.keys or {}
      opts.move.keys.goto_next_start = vim.tbl_deep_extend("force", opts.move.keys.goto_next_start or {}, {
        ["]l"] = "@loop.outer",
      })
      opts.move.keys.goto_next_end = vim.tbl_deep_extend("force", opts.move.keys.goto_next_end or {}, {
        ["]L"] = "@loop.outer",
      })
      opts.move.keys.goto_previous_start = vim.tbl_deep_extend("force", opts.move.keys.goto_previous_start or {}, {
        ["[l"] = "@loop.outer",
      })
      opts.move.keys.goto_previous_end = vim.tbl_deep_extend("force", opts.move.keys.goto_previous_end or {}, {
        ["[L"] = "@loop.outer",
      })
    end,
  },
}
