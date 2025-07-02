local opts = { noremap = true, silent = true }


vim.api.nvim_set_keymap('n', '<leader>pv', ':lua MiniFiles.open()<CR>', opts)

-- Toggle between the latest buffers
vim.api.nvim_set_keymap('n', '<leader>n', '<C-^>', opts)

-- yank / paste 
vim.api.nvim_set_keymap('v', 'g#', '"+y', opts) -- Yank to system clipboard  
vim.api.nvim_set_keymap('n', 'gp', '"+p', opts) -- Paste from system clipboard  

vim.api.nvim_set_keymap('n', '<leader>ab', 'i```<CR>~<CR><CR>```<Esc>O', opts)
-- Quickfix navigation with wrapping
vim.api.nvim_set_keymap('n', '<C-n>', ':lua if vim.fn.getqflist({idx=0}).idx == #vim.fn.getqflist() then vim.cmd("cfirst") else vim.cmd("cnext") end<CR>zz', opts)
vim.api.nvim_set_keymap('n', '<C-p>', ':lua if vim.fn.getqflist({idx=0}).idx == 1 then vim.cmd("clast") else vim.cmd("cprev") end<CR>zz', opts)
--
-- Text formatting mappings
vim.api.nvim_set_keymap('n', '<leader>mb', 'i****<Esc>hi', opts)  -- Make bold
vim.api.nvim_set_keymap('n', '<leader>mi', 'i**<Esc>i', opts)   -- Make italic
vim.api.nvim_set_keymap('n', '<leader>mI', 'i++++<Esc>hi', opts)  -- Make insert
vim.api.nvim_set_keymap('n', '<leader>mn', 'i***++++***<Esc>4hi', opts)  -- Make bold+italic+insert
vim.api.nvim_set_keymap('n', '<leader>hn', 'i***++++***<Esc>4hi', opts)  -- Make bold+italic+insert
vim.api.nvim_set_keymap('n', '<leader>hn', [[:lua vim.wo.number = not vim.wo.number; vim.wo.relativenumber = vim.wo.number<CR>]], { noremap = true, silent = true })

-- -- Smart fullscreen toggle: <C-f> zooms in/out current split
-- local is_zoomed = false
-- local zoomed_win = nil
--
-- vim.keymap.set('n', '<C-f>', function()
--   local cur_win = vim.api.nvim_get_current_win()
--
--   if is_zoomed and zoomed_win == cur_win then
--     -- same window → unzoom
--     vim.cmd('wincmd =')
--     is_zoomed = false
--     zoomed_win = nil
--   else
--     -- new window or not zoomed yet → zoom in
--     vim.cmd('wincmd _')  -- max height
--     vim.cmd('wincmd |')  -- max width
--     is_zoomed = true
--     zoomed_win = cur_win
--   end
-- end, { noremap = true, silent = true })


-- Fullscreen Mode Toggle + Smart Navigation Zooming
local fullscreen_mode = false

-- enable fullscreen for current window
local function zoom()
  vim.cmd('wincmd _') -- max height
  vim.cmd('wincmd |') -- max width
end

-- restore all windows
local function unzoom()
  vim.cmd('wincmd =')
end

-- toggle fullscreen mode with <C-f>
vim.keymap.set('n', '<C-f>', function()
  fullscreen_mode = not fullscreen_mode
  if fullscreen_mode then
    zoom()
  else
    unzoom()
  end
end, { noremap = true, silent = true })

-- wrapper to move focus and zoom if in fullscreen mode
local function nav_and_zoom(cmd)
  return function()
    vim.cmd('wincmd ' .. cmd)
    if fullscreen_mode then
      zoom()
    end
  end
end

-- remap split nav keys to include zoom logic
vim.keymap.set('n', '<C-h>', nav_and_zoom('h'), { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', nav_and_zoom('j'), { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', nav_and_zoom('k'), { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', nav_and_zoom('l'), { noremap = true, silent = true })
