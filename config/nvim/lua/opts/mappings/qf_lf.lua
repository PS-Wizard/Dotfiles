local opts = { noremap = true, silent = true }
-- Quickfix navigation with wrapping
local function smart_qf_loc_next()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        local loc = vim.fn.getloclist(0, { idx = 0, size = 0 })
        if loc.idx == loc.size then
            vim.cmd("lfirst")
        else
            vim.cmd("lnext")
        end
    elseif vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        local qf = vim.fn.getqflist({ idx = 0, size = 0 })
        if qf.idx == qf.size then
            vim.cmd("cfirst")
        else
            vim.cmd("cnext")
        end
    end
    vim.cmd("normal! zz")
end
local function smart_qf_loc_prev()
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        local loc = vim.fn.getloclist(0, { idx = 0 })
        if loc.idx == 1 then
            vim.cmd("llast")
        else
            vim.cmd("lprev")
        end
    elseif vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
        local qf = vim.fn.getqflist({ idx = 0 })
        if qf.idx == 1 then
            vim.cmd("clast")
        else
            vim.cmd("cprev")
        end
    end
    vim.cmd("normal! zz")
end
vim.keymap.set('n', '<C-n>', smart_qf_loc_next, { noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', smart_qf_loc_prev, { noremap = true, silent = true })
function OpenQuickfixInVSplits()
    -- Get all quickfix items
    local qf_list = vim.fn.getqflist()
    
    -- Return if quickfix list is empty
    if #qf_list == 0 then
        print("Quickfix list is empty")
        return
    end
    
    -- Close any existing windows to start fresh
    vim.cmd('wincmd o')
    
    -- Open each file in a vertical split
    for i, item in ipairs(qf_list) do
        if item.valid == 1 and item.bufnr > 0 then
            -- Open new vertical split for all but first item
            if i > 1 then
                vim.cmd('vsplit')
            end
            
            -- Open the file and go to the specific line
            vim.cmd('buffer ' .. item.bufnr)
            vim.fn.cursor(item.lnum, item.col)
        end
    end
    
    -- Move cursor to first window
    vim.cmd('wincmd h')
end
