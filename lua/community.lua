--if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.html-css" },
  -- Rust 开发已迁移到 VS Code（2026-08-29），不再引入 astrocommunity.pack.rust
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
  { import = "astrocommunity.git.mini-git" },
  { import = "astrocommunity.colorscheme.catppuccin" },
}
