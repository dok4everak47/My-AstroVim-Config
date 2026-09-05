-- rust-analyzer 补全：函数自动补全括号（2026-09-04）
-- 现象：补全 `Some`/`Ok` 等函数只出名字，不带 `()`。
-- 根因：rust-analyzer 默认 completion.callable.snippets = "none"（只补函数名）。
-- 这里设为 "fill_arguments"：可调用项补全自动带 `()` 并预填参数占位（$1...）。
--   可选值：none（默认）/ add_parenthesis（只加 () 不填参）/ fill_arguments（加 () + 预填参）。
-- 用 opts 函数深合并进 LazyVim rust extra 已设的 default_settings，不覆盖其它键。
return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server = opts.server or {}
      opts.server.default_settings = opts.server.default_settings or {}
      local ra = opts.server.default_settings["rust-analyzer"] or {}
      ra.completion = vim.tbl_deep_extend("force", ra.completion or {}, {
        callable = {
          snippets = "fill_arguments",
        },
        -- 自定义 snippet：println! 宏补全默认只出 println!()（无参数占位，宏不走
        -- fill_arguments），这里提供带 fmt 字符串 + args 两个占位的版本。
        -- 补全列表会出现额外一项（描述 "println!(\"…\", …)"），选中即展开
        -- println!("$1", $2) 光标在 $1，Tab 跳 $2。prefix 匹配 "println"。
        snippets = {
          custom = {
            ["println!"] = {
              prefix = { "println" },
              body = 'println!("$1", $2)$0',
              description = 'println!("…", …)',
              scope = "expr",
            },
            ["eprintln!"] = {
              prefix = { "eprintln" },
              body = 'eprintln!("$1", $2)$0',
              description = 'eprintln!("…", …)',
              scope = "expr",
            },
            ["print!"] = {
              prefix = { "print" },
              body = 'print!("$1", $2)$0',
              description = 'print!("…", …)',
              scope = "expr",
            },
          },
        },
      })
      opts.server.default_settings["rust-analyzer"] = ra
    end,
  },
}
