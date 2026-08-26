require("vim._core.ui2").enable({})

require("options")
require("keymaps")
require("pack")
require("lsp")
require("todo").setup({ path = "~/Projects/gnosis/tasks/" })

vim.cmd.colorscheme("nemo")
require("filename")
