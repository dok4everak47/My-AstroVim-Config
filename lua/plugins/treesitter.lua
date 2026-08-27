-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        -- Web / TypeScript
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "json",
        "jsonc",
        "html",
        "css",
        "scss",
        "vue",
        -- Elm
        "elm",
        -- config / data
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        "gitcommit",
        "bash",
        "regex",
      },
      highlight = {
        enable = true,
        -- disable slow treesitter highlight for large files
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then return true end
        end,
      },
      -- 变量重命名/闭合标签等 incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      indent = {
        enable = true,
        disable = { "elm" },
      },
    },
  },
  -- nvim-treesitter-textobjects is disabled: both its `main` branch and the
  -- nvim-treesitter `master` branch it depends on are frozen/archived, and the
  -- legacy `nvim-treesitter.configs`/`query` API is incompatible with nvim 0.12's
  -- `vim.treesitter`. Any textobject (e.g. `vif`/`af`/`]f`) raises:
  --   tsrange.lua:27: attempt to call method 'start' (a nil value)
  -- Function textobjects (`if`/`af`) are provided natively via `vim.treesitter`
  -- in lua/polish.lua instead.
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
}
