return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },
  {
    "stevearc/aerial.nvim",
    opts = {
      on_attach = function(bufnr)
        -- vim.api.nvim_set_keymap("n", "<C-a>", map.inc_normal "mygroup", { noremap = true })
        vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>")
        vim.keymap.set("n", "<leader>ss", "<cmd>Telescope aerial<CR>")
      end,
    },
    event = "VeryLazy",
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>o", desc = "Toggle outline" },
      { "<leader>ss", decs = "Search symbols in file" },
    },
  },
}
