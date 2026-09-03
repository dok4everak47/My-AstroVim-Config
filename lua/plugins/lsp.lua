-- 语言服务器补充配置（原 AstroNvim astrolsp.lua 迁移）
-- 需要手动指定 cmd/init_options 的服务：elmls、nil_ls（nix-darwin/devShell 装，非 mason）
-- 注：lang.elm / lang.nix extras 已声明 elmls/nil_ls，这里覆盖 cmd 指向 nix/devShell 二进制

-- Nix 工具路径解析（PATH → 当前目录 .direnv → 用户 nix profile → 系统 profile）
-- GUI 启动的 nvim 从 launchd 继承的 PATH 不含 nix profile，必须显式给绝对路径
local function nix_bin(name)
  local path = vim.fn.exepath(name)
  if path ~= "" then
    return path
  end
  local cwd = vim.fn.getcwd()
  local direnv_path = cwd .. "/.direnv/bin/" .. name
  if vim.fn.filereadable(direnv_path) == 1 then
    return direnv_path
  end
  local user_path = "/Users/dok4ever/.nix-profile/bin/" .. name
  if vim.fn.filereadable(user_path) == 1 then
    return user_path
  end
  return "/run/current-system/sw/bin/" .. name
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- elmls：GUI 启动 PATH 常缺 nix profile，显式给 cmd + init_options
        -- mason=false：elmls 不在 mason registry，避免 LazyVim 尝试 mason 安装
        elmls = {
          mason = false,
          cmd = { nix_bin("elm-language-server") },
          init_options = {
            elmPath = nix_bin("elm"),
            elmFormatPath = nix_bin("elm-format"),
            elmTestPath = nix_bin("elm-test-rs"),
            elmReviewPath = nix_bin("elm-review"),
          },
        },
        -- nil_ls（Nix LSP）：系统 profile 已装，非 mason；GUI 启动 PATH 缺系统 profile，
        -- 显式给绝对路径 cmd（/run/current-system/sw/bin/nil）
        nil_ls = {
          mason = false,
          cmd = { nix_bin("nil") },
        },
      },
    },
  },
  -- 关闭 nix 文件的 statix lint（statix 未全局安装，遵循 Nix 铁律：工具走 devShell；
  -- nil_ls 已提供诊断，statix 属可选 linter，避免打开 nix 文件报 ENOENT）
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.nix = nil -- 移除 nix 的 statix，nil_ls 诊断已足够
    end,
  },
}
