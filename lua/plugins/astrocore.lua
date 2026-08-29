-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Treesitter 配置（AstroNvim v6：highlight/indent/auto_install/textobjects 由 AstroCore 默认提供）
    -- 这里只补充默认之外需要安装的 parser；列表与 AstroCore 默认 ensure_installed 合并去重
    treesitter = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        -- Web / TypeScript
        "javascript", "typescript", "tsx", "jsdoc", "json",
        "html", "css", "scss", "vue",
        -- Elm
        "elm",
        -- config / data
        "yaml", "toml", "markdown", "markdown_inline", "gitcommit", "bash", "regex",
        -- C/C++/Python（C/C++ 在 polish.lua 有执行映射）
        "c", "cpp", "python",
      },
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["<leader>lv"] = { "<cmd>VenvSelect<cr>", desc = "选择虚拟环境" },
        ["<leader>lc"] = { "<cmd>VenvSelectCached<cr>", desc = "选择缓存的虚拟环境" },
        -- Cmd+S / Ctrl+S 保存（BufWritePre 的 format_on_save 会自动跑 elm-format）
        ["<D-s>"] = { "<Cmd>w<CR>", desc = "Save" },
        ["<C-s>"] = { "<Cmd>w<CR>", desc = "Save" },
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      i = {
        -- 插入模式下 Cmd+S / Ctrl+S：先存盘，命令执行完自动回到插入模式
        ["<D-s>"] = { "<Cmd>w<CR>", desc = "Save" },
        ["<C-s>"] = { "<Cmd>w<CR>", desc = "Save" },
      },
      v = {
        ["<D-s>"] = { "<Cmd>w<CR>", desc = "Save" },
        ["<C-s>"] = { "<Cmd>w<CR>", desc = "Save" },
      },
    },
    autocmds = {
      -- 退出 nvim 前主动停 LSP（治 rust-analyzer 孤儿进程高温病根，2026-08-29）
      -- 注意：astrocore 的 autocmds 键是分组名，每条必须显式写 event
      vim_leave_pre = {
        {
          event = "VimLeavePre",
          callback = function()
            -- 拿到所有 LSP 客户端，逐个停
            local clients = vim.lsp.get_clients()
            for _, client in ipairs(clients) do
              pcall(vim.lsp.stop_client, client, true) -- true = force
            end
          end,
          desc = "退出前停所有 LSP 客户端（治孤儿进程）",
        },
      },
    },
  },
}
