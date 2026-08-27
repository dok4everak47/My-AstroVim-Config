-- blink.cmp tweaks: prioritize snippet completions (like VS Code statement expansion)
-- and label snippet items distinctly in the menu.

---@type LazySpec
return {
  "Saghen/blink.cmp",
  opts = {
    -- Neutralize the default -3 penalty so snippets can compete with LSP keywords.
    snippets = { score_offset = 0 },

    sources = {
      -- Per-provider score offsets. Larger = higher in the menu.
      -- snippets provider gets a further +1 so `if`/`for`/`while` etc. rank above
      -- the plain keyword text completion from vtsls.
      providers = {
        snippets = { score_offset = 1 },
        lsp = { score_offset = 0 },
        path = { score_offset = 2 },
        buffer = { score_offset = -3 },
      },
    },

    completion = {
      list = {
        -- Show recently used / higher quality items first within equal scores.
        selection = { preselect = true, auto_insert = false },
      },
      menu = {
        draw = {
          components = {
            -- Append a small "~S" badge on snippet items so they're easy to spot.
            label = {
              text = function(ctx)
                if ctx.item.source_name == "Snippets" then
                  return ctx.label .. " ~S"
                end
                return ctx.label
              end,
            },
          },
        },
      },
    },
  },
}
