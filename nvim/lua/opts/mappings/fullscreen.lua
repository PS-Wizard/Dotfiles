local opts = { noremap = true, silent = true }
local function zoom()
  vim.cmd('resize')       -- Force recalculation
  vim.cmd('wincmd _')     -- max height
  vim.cmd('wincmd |')     -- max width
end
-- restore all windows
local function unzoom()
  vim.cmd('wincmd =')
end
-- Auto-zoom on window enter (except quickfix/loclist)
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    zoom()
  end,
})
vim.keymap.set('n', '<C-f>', function()
  unzoom()  -- Just unzoom to show all splits equally
end, { noremap = true, silent = true })
-- Normal navigation - autocmd will handle zooming
vim.keymap.set('n', '<C-h>', '<cmd>wincmd h<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<cmd>wincmd j<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<cmd>wincmd k<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<cmd>wincmd l<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ww', '<cmd>cclose<cr>')
