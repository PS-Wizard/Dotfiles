require ('opts.preferences')
require ('opts.mappings')
require('config.lazy')
vim.cmd("colorscheme wizard")

-- local client = vim.lsp.start_client {
--     name = "lsp_rust",
--     cmd = { "/home/wizard/Rust_LSP/target/debug/rust-lsp" },
--     on_attach = function(client,buffer)
--         local opts = { noremap=true, silent=true, buffer=bufnr }
--         vim.api.nvim_buf_set_keymap.set(buffer,'n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
--         vim.api.nvim_buf_set_keymap.set(buffer,'n', 'K','<cmd> vim.lsp.buf.hover()<CR>' , opts)
--         vim.api.nvim_buf_set_keymap.set(buffer,'n', '<leader>ca','<cmd>vim.lsp.buf.code_action()' , opts)
--     end,
-- }
--
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "markdown",
--     callback = function()
--         vim.notify("im in boie", vim.log.levels.INFO)
--         vim.lsp.buf_attach_client(0,client)
--     end
-- })
