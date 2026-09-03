-- neo-tree 个性化（原 AstroNvim user.lua 迁移）
-- LazyVim editor.neo-tree extra 已提供默认（<leader>e 打开、git 状态等），
-- 这里只保留你 AstroNvim 时期的核心偏好：跟随当前文件 + 显示隐藏文件。

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true, -- 显示隐藏文件
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
            "node_modules",
            ".DS_Store",
            "thumbs.db",
          },
        },
      })
      opts.buffers = vim.tbl_deep_extend("force", opts.buffers or {}, {
        follow_current_file = { enabled = true },
      })
    end,
  },
}
