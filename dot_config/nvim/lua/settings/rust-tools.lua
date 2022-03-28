local lspconfig = require 'settings.lspconfig'

local M = {}

function M.setup()
    local server = vim.tbl_deep_extend('force', lspconfig.make_default_opts(), {
        cmd = { 'rustup', 'run', 'nightly', 'rust-analyzer' },
        flags = { allow_incremental_sync = true },
        settings = {
            ['rust-analyzer'] = {
                assist = { importGranularity = 'module', importPrefix = 'by_self' },
                cargo = { loadOutDirsFromCheck = true, allFeatures = true },
                procMacro = { enable = true },
                checkOnSave = { command = 'clippy' },
                experimental = { procAttrMacros = true },
                lens = { methodReferences = true, references = true },
            },
        },
    })

    local opts = { server = server }

    require('rust-tools').setup(opts)
end

return M
