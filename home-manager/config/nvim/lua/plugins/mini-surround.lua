return {
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup {
        mappings = {
          add = "ys",
          delete = "ds",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          replace = "cs",
          update_n_lines = "gsn",
        },
      }
    end,
  },
}
