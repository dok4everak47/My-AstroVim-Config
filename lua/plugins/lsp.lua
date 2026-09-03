-- 语言服务器补充配置（原 AstroNvim astrolsp.lua 迁移）
-- 需要手动指定 cmd/init_options 的服务：elmls、nil_ls（nix-darwin/devShell 装，非 mason）
-- 注：lang.elm / lang.nix extras 已声明 elmls/nil_ls，这里覆盖 cmd 指向 nix/devShell 二进制

-- Elm 工具路径解析（devShell/direnv → 用户 nix profile → 系统 profile）
local function elm_bin(name)
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
  return "/nix/var/nix/profiles/system/sw/bin/" .. name
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
          cmd = { elm_bin("elm-language-server") },
          init_options = {
            elmPath = elm_bin("elm"),
            elmFormatPath = elm_bin("elm-format"),
            elmTestPath = elm_bin("elm-test-rs"),
            elmReviewPath = elm_bin("elm-review"),
          },
        },
        -- nil_ls（Nix LSP）：系统 profile 已装，非 mason
        nil_ls = {
          mason = false,
        },
      },
    },
  },
}
