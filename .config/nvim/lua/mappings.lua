require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<C-j>", "<cmd>bn<CR>", { desc = "Move to next tab" })
map("n", "<C-k>", "<cmd>bp<CR>", { desc = "Move to previous tab" })
map("n", "K", "<C-u>", { desc = "Move Up" })
map("n", "J", "<C-d>", { desc = "Move Down" })
map("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})
