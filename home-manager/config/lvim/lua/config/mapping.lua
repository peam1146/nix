lvim.builtin.which_key.mappings["w"] = { "<cmd>lua require('lvim.lsp.utils').format()<CR>", "Format document" }

-- Ctrl + s to save
lvim.lsp.buffer_mappings.normal_mode["<C-s>"] = { "<cmd>w<CR>", "Save buffer" }
