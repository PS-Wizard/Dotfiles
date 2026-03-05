local M = {}
local watch_job = nil
local zathura_job = nil
local tmp_pdf = "/tmp/typst-preview.pdf"

local function kill_watch()
    if watch_job then
        vim.fn.jobstop(watch_job)
        watch_job = nil
    end
end

local function start_watch(typ_file)
    kill_watch()
    watch_job = vim.fn.jobstart({
        "typst", "watch", typ_file, tmp_pdf
    }, {
        on_exit = function() watch_job = nil end,
    })
end

local function ensure_zathura()
    if zathura_job and vim.fn.jobwait({ zathura_job }, 0)[1] == -1 then
        return
    end
    vim.defer_fn(function()
        zathura_job = vim.fn.jobstart({ "zathura", tmp_pdf }, {
            on_exit = function()
                zathura_job = nil
                kill_watch()
            end,
        })
    end, 500)
end

function M.preview()
    local typ_file = vim.fn.expand("%:p")
    if vim.fn.fnamemodify(typ_file, ":e") ~= "typ" then
        vim.notify("Not a typst file", vim.log.levels.WARN)
        return
    end
    start_watch(typ_file)
    ensure_zathura()
    vim.notify("Typst watch started → " .. tmp_pdf)
end

return M
