vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

vim.g.lazy_events_config = {
  simple = {
    LazyFile = { "BufReadPost", "BufNewFile", "BufWritePre" },
  },
}

if vim.g.vscode then
  -- vscode
  -- vim.notify = vscode.notify

  local nomap = vim.keymap.del
  local map = vim.keymap.set
  local vscode = require "vscode"
  vim.notify = vscode.notify
  vim.g.clipboard = vim.g.vscode_clipboard
  vim.api.nvim_set_option_value("clipboard", "unnamedplus", { scope = "global" })

  -- set relative number
  vim.opt.relativenumber = true
  local path_package = vim.fn.stdpath "data" .. "/site/"
  local mini_path = path_package .. "pack/deps/start/mini.nvim"
  if not vim.loop.fs_stat(mini_path) then
    vim.cmd 'echo "Installing `mini.nvim`" | redraw'
    local clone_cmd = {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/echasnovski/mini.nvim",
      mini_path,
    }
    vim.fn.system(clone_cmd)
    vim.cmd "packadd mini.nvim | helptags ALL"
    vim.cmd 'echo "Installed `mini.nvim`" | redraw'
  end

  -- Set up 'mini.deps' (customize to your liking)
  require("mini.deps").setup { path = { package = path_package } }

  -- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
  -- startup and are optional.
  local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

  -- later(add "ggandor/leap.nvim")
  later(add "folke/flash.nvim")
  later(add "echasnovski/mini.surround")

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

  map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
  map("i", "<C-e>", "<End>", { desc = "move end of line" })
  map("i", "<C-h>", "<Left>", { desc = "move left" })
  map("i", "<C-l>", "<Right>", { desc = "move right" })
  map("i", "<C-j>", "<Down>", { desc = "move down" })
  map("i", "<C-k>", "<Up>", { desc = "move up" })

  map("n", "<C-h>", function()
    vscode.action "workbench.action.navigateLeft"
  end, { desc = "switch window left" })

  map("n", "<C-l>", function()
    vscode.action "workbench.action.navigateRight"
  end, { desc = "switch window right" })

  map("n", "<C-j>", function()
    vscode.action "workbench.action.navigateDown"
  end, { desc = "switch window down" })
  map("n", "<C-k>", function()
    vscode.action "workbench.action.navigateUp"
  end, { desc = "switch window up" })

  map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

  map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
  map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

  map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
  map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
  map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

  map({ "n", "x" }, "<leader>fm", function()
    -- require("conform").format { lsp_fallback = true }
    vscode.action "editor.action.formatDocument"
  end, { desc = "general format file" })

  -- map({ "n", "x" }, "<leader>ff", function()
  --   -- require("conform").format { lsp_fallback = true }
  --   vscode.action "editor.action.formatDocument"
  -- end, { desc = "Open Vscode command pallate" })

  map("n", "<leader>r", function()
    vscode.with_insert(function()
      vscode.action "editor.action.refactor"
    end)
  end, { desc = "refactor" })

  -- global lsp mappings
  -- map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

  -- tabufline
  map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

  map("n", "<tab>", function()
    require("nvchad.tabufline").next()
  end, { desc = "buffer goto next" })

  map("n", "<S-tab>", function()
    require("nvchad.tabufline").prev()
  end, { desc = "buffer goto prev" })

  map("n", "<leader>x", function()
    require("nvchad.tabufline").close_buffer()
  end, { desc = "buffer close" })

  -- Comment
  map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
  map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

  -- nvimtree
  map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
  map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

  -- telescope
  -- map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
  -- map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
  -- map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
  -- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
  -- map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
  -- map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
  -- map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
  -- map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
  -- map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

  -- map("n", "<leader>th", function()
  --   require("nvchad.themes").open()
  -- end, { desc = "telescope nvchad themes" })
  --
  -- map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
  -- map(
  --   "n",
  --   "<leader>fa",
  --   "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  --   { desc = "telescope find all files" }
  -- )

  -- terminal
  map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

  -- new terminals
  map("n", "<leader>h", function()
    require("nvchad.term").new { pos = "sp" }
  end, { desc = "terminal new horizontal term" })

  map("n", "<leader>v", function()
    require("nvchad.term").new { pos = "vsp" }
  end, { desc = "terminal new vertical term" })

  -- toggleable
  map({ "n", "t" }, "<A-v>", function()
    require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
  end, { desc = "terminal toggleable vertical term" })

  map({ "n", "t" }, "<A-h>", function()
    require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  end, { desc = "terminal toggleable horizontal term" })

  map({ "n", "t" }, "<A-i>", function()
    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
  end, { desc = "terminal toggle floating term" })

  -- whichkey
  map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

  map("n", "<leader>wk", function()
    vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
  end, { desc = "whichkey query lookup" })

  -- add yours here
  nomap("n", "<leader>e")

  map("n", ";", ":", { desc = "CMD enter command mode" })

  map("n", "[d", function()
    vscode.action "editor.action.marker.nextInFiles"
  end, { desc = "diagnostic next" })

  map("n", "]d", function()
    vscode.action "editor.action.marker.prevInFiles"
  end, { desc = "diagnostic prev" })

  -- buffers
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
  map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

  -- keys = {
  --   { "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  --   { "Ss", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  --   { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
  --   { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  --   { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  -- },
  map("n", "<leader>ss", function()
    require("flash").jump()
  end, { desc = "Flash" })
else
  -- load plugins
  require("lazy").setup({
    { "bwpge/lazy-events.nvim", import = "lazy-events.import", lazy = false },
    {
      "NvChad/NvChad",
      lazy = false,
      branch = "v2.5",
      import = "nvchad.plugins",
    },
    { import = "plugins" },
  }, lazy_config)

  -- load theme
  dofile(vim.g.base46_cache .. "defaults")
  dofile(vim.g.base46_cache .. "statusline")

  require "options"
  require "nvchad.autocmds"

  local autocmds = vim.api.nvim_create_autocmd

  -- highlight on yank
  autocmds("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", {}),
    desc = "Hightlight selection on yank",
    pattern = "*",
    callback = function()
      vim.highlight.on_yank { higroup = "IncSearch", timeout = 200 }
    end,
  })

  vim.schedule(function()
    require "mappings"
  end)

  -- ordinary Neovim
end
