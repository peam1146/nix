return {
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    keys = {
      { "<leader>Gc", "<cmd>GoCmt<cr>", desc = "Add comments" },
      { "<leader>Gf", "<cmd>GoFillStruct<cr>", desc = "Auto fill struct" },
      { "<leader>GF", "<cmd>GoFillSwitch<cr>", desc = "Fill switch" },
      { "<leader>Gi", "<cmd>GoIfErr<cr>", desc = "Add if err" },
      { "<leader>Gp", "<cmd>GoFixPlurals<cr>", desc = "Change func foo(b int, a int, r int) -> func foo(b, a, r int)" },
      { "<leader>Gg", "<cmd>GoGenerate<cr>", desc = "go generate" },
      { "<leader>Gr", "<cmd>GoGenReturn<cr>", desc = "go gen return" },
      { "<leader>Gt", desc = "+tags" },
      { "<leader>Gta", "<cmd>GoAddTag<cr>", desc = "Add tag" },
      { "<leader>Gtr", "<cmd>GoRmTag<cr>", desc = "Remove tag" },
      { "<leader>Gtc", "<cmd>GoClearTag<cr>", desc = "Clear tag" },
    },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
}
