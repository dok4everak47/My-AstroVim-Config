return {
  {
    "CRAG666/code_runner.nvim",
    config = function()
      require("code_runner").setup {
        filetype = {
          cpp = "cd $dir && g++ -std=c++17 $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
        },
      }
    end,
  },
}
