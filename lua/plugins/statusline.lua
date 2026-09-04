-- Lualine statusline 增强：在 LazyVim 默认基础上追加更丰富的信息
-- LazyVim 默认已含: mode/branch/diagnostics/filetype/路径/diff/进度/行号/时钟
-- 这里追加: LSP 客户端、编码/换行、缩进、visual 选中行数、搜索计数、git 上游
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      for _, sec in ipairs({ "lualine_a", "lualine_b", "lualine_c", "lualine_x", "lualine_y", "lualine_z" }) do
        opts.sections[sec] = opts.sections[sec] or {}
      end

      -- 取当前 buffer 激活的 LSP 客户端名 (跳过 null-ls/copilot 等辅助)
      local function active_lsp_name()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, c in ipairs(clients) do
          if c.name ~= "null-ls" and c.name ~= "copilot" then
            return c.name
          end
        end
        return #clients > 0 and clients[1].name or ""
      end

      -- c 段: LSP 客户端名 (e.g. rust-analyzer / basedpyright)
      table.insert(opts.sections.lualine_c, {
        function()
          return "λ " .. active_lsp_name()
        end,
        cond = function()
          return active_lsp_name() ~= ""
        end,
      })

      -- c 段: 编码/换行 (UTF-8/LF)
      table.insert(opts.sections.lualine_c, {
        function()
          local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
          local ff = vim.bo.fileformat == "dos" and "CRLF" or vim.bo.fileformat == "mac" and "CR" or "LF"
          return enc:upper() .. "/" .. ff
        end,
      })

      -- c 段: 缩进 (2sp / tab4)
      table.insert(opts.sections.lualine_c, {
        function()
          local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
          return tostring(sw) .. (vim.bo.expandtab and "sp" or "tb")
        end,
      })

      -- x 段(最前): git 上游分支
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local up = vim.b.gitsigns_upstream
          if up and up ~= "" then
            return "󰛃 " .. up
          end
          return ""
        end,
        cond = function()
          return vim.b.gitsigns_upstream ~= nil and vim.b.gitsigns_upstream ~= ""
        end,
      })

      -- y 段: visual 模式选中行数
      table.insert(opts.sections.lualine_y, {
        function()
          return "L" .. (math.abs(vim.fn.line("v") - vim.fn.line(".")) + 1)
        end,
        cond = function()
          local m = vim.fn.mode()
          return m == "v" or m == "V"
        end,
      })

      -- y 段: 搜索计数 current/total
      table.insert(opts.sections.lualine_y, {
        function()
          local ok, sc = pcall(vim.fn.searchcount, { recompute = false })
          if ok and sc and sc.total and sc.total > 0 and sc.current then
            return sc.current .. "/" .. sc.total
          end
          return ""
        end,
      })
    end,
  },
}
