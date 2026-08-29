-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

-- 解析 Elm 工具路径：优先取 devShell/direnv 激活的 PATH，再 fallback
-- 2026-08-29：全局 elm 套件已从 nix-darwin 移除，改从项目 devShell 找
local function elm_bin(name)
  -- 1. 当前 PATH（direnv 激活时含项目 devShell 的 .direnv/bin）
  local path = vim.fn.exepath(name)
  if path ~= "" then return path end
  -- 2. 当前目录 .direnv/bin（direnv 装的 nix profile 二进制）
  local cwd = vim.fn.getcwd()
  local direnv_path = cwd .. "/.direnv/bin/" .. name
  if vim.fn.filereadable(direnv_path) == 1 then return direnv_path end
  -- 3. 用户 nix profile
  local user_path = "/Users/dok4ever/.nix-profile/bin/" .. name
  if vim.fn.filereadable(user_path) == 1 then return user_path end
  -- 4. 最后 fallback 到系统 profile（可能已不存在）
  return "/nix/var/nix/profiles/system/sw/bin/" .. name
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
        "elmls", -- Elm 格式化交给 none-ls 的 elm_format（独立二进制），避免双 formatter 冲突
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
      "elmls", -- Elm LSP（nix-darwin 已声明安装，无需 Mason）
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      elmls = {
        -- v4 走 vim.lsp.config / vim.lsp.enable（nvim 原生 LSP）
        -- 显式指定 cmd，GUI 启动 PATH 缺 nix profile 也能拉起 LSP
        cmd = { elm_bin "elm-language-server" },
        init_options = {
          -- 显式指定工具路径，即使 GUI 启动导致 PATH 缺少 nix profile 也能正常工作
          elmPath = elm_bin "elm",
          elmFormatPath = elm_bin "elm-format",
          elmTestPath = elm_bin "elm-test-rs",
          elmReviewPath = elm_bin "elm-review",
        },
      },
    },
    -- AstroLSP v4：默认 handler 即 vim.lsp.enable，servers 列表直接启用，
    -- 旧的 lspconfig 手动 setup（v3 写法）已废弃且会导致 opts=nil 崩溃，故删除
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gd = {
          function() vim.lsp.buf.definition() end,
          desc = "Go to definition of current symbol",
          cond = "textDocument/definition",
        },
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        gi = {
          function() vim.lsp.buf.implementation() end,
          desc = "Go to implementation of current symbol",
          cond = "textDocument/implementation",
        },
        gr = {
          function() vim.lsp.buf.references() end,
          desc = "Go to references of current symbol",
          cond = "textDocument/references",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
