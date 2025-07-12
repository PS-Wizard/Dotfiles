
local opts = { noremap = true, silent = true }

local fullscreen_mode = false

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
