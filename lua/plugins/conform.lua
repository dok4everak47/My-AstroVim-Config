-- conform.nvim 格式化（原 AstroNvim none-ls/astrolsp.formatting 迁移到 LazyVim conform）
-- 说明：LazyVim 的 conform 由 LazyVim/formatting 统一管理，不要在 opts 里设
-- format_on_save（LazyVim 用 vim.g.lazyvim_format_on_save 控制，见 options.lua）。
-- elm/nix 的 formatters_by_ft 由 extras（lang.elm / lang.nix）提供，
-- 这里只补充「自定义二进制路径」与默认外的 formatter。

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Nix 用 alejandra（nix-darwin 系统 profile 已装，非 mason）——覆盖 extra 默认的 nixfmt
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        nix = { "alejandra" },
      })

      -- elm_format：优先项目 devShell/.direnv 的 elm-format，fallback PATH(mason)
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        elm_format = {
          command = function()
            local cwd = vim.fn.getcwd()
            local direnv_path = cwd .. "/.direnv/bin/elm-format"
            if vim.fn.filereadable(direnv_path) == 1 then
              return direnv_path
            end
            return vim.fn.exepath("elm-format")
          end,
          args = { "--elm-version=0.19" },
        },
      })
    end,
  },
}
