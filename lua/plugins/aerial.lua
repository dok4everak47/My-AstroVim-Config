-- Override AstroNvim's version pin for aerial.nvim.
--
-- AstroNvim (version tracking enabled) pins aerial to `^2.2` via
-- `astronvim.lazy_snapshot`, but the 2.x line is incompatible with
-- Neovim 0.12+ (node:start()/node:range() and iter_matches changes),
-- causing "attempt to call method 'start' (a nil value)" on Lua files.
-- `^4` resolves to v4.0.0, the first release line with full Neovim 0.12 support.

---@type LazySpec
return {
  {
    "stevearc/aerial.nvim",
    version = "^4",
    optional = true,
  },
}
