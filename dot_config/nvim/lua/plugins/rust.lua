return {
    { -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        ft = 'rust',
        config = function()
            local server = vim.tbl_deep_extend('force', require('plugins.utils.lsp').make_default_opts(), {
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
        end,
    },
    { -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        ft = 'rust',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('crates').setup()
        end,
    },
}
