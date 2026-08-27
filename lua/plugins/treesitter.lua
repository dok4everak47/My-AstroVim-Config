-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter (AstroNvim v6 / nvim-treesitter `main` branch)
--
-- nvim-treesitter `main` is a full, incompatible rewrite. Configuration of
-- highlight / indent / auto_install / textobjects now lives under AstroCore
-- options (`opts.treesitter` in lua/plugins/astrocore.lua), NOT in this
-- plugin's opts. `ensure_installed` parsers are configured there as well.
--
-- This file intentionally returns an empty spec: AstroNvim's default
-- nvim-treesitter spec (branch = "main", build = ":TSUpdate") is sufficient.
-- Incremental selection (`<C-space>` / `<bs>`) is provided natively in
-- lua/polish.lua, since nvim-treesitter `main` removed that module.

---@type LazySpec
return {}
