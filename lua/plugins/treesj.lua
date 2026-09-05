-- treesj: 代码块 单行/多行 互转 (2026-09-05)
-- 基于 treesitter 语法树: 光标在 if/函数调用/数组等节点上,
--   <leader>tj = 合并成一行 (join), <leader>ts = 展开成多行 (split), <leader>tt = 切换
-- 关掉默认键 (<space>m/j/s 与 LazyVim 的 leader 空格冲突), 用 <leader>t* 前缀。
return {
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>tt", function() require("treesj").toggle() end, desc = "Toggle single/multi line" },
      { "<leader>tj", function() require("treesj").join() end, desc = "Join to single line" },
      { "<leader>ts", function() require("treesj").split() end, desc = "Split to multi line" },
    },
    opts = {
      use_default_keymaps = false,
      check_syntax_error = true,
      max_join_length = 120,
    },
  },
}
