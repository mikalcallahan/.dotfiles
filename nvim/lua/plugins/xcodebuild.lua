return {
  "wojciech-kulik/xcodebuild.nvim",
  event = "BufReadPre",
  config = function()
    require("xcodebuild").setup({
      -- put some options here or leave it empty to use default settings
    })
  end,
}
