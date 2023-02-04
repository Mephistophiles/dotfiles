return { -- (Neo)Vim plugin for automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
    'RRethy/vim-illuminate',
    event = 'CursorHold',
    config = function()
        local augroup = vim.api.nvim_create_augroup('IlluminatedAugroup', { clear = true })

        vim.api.nvim_create_autocmd('VimEnter', {
            group = augroup,
            pattern = '*',
            desc = 'Override highlight',
            callback = function()
                vim.api.nvim_set_hl(0, 'illuminatedWord', { underline = true })
                vim.api.nvim_set_hl(0, 'IlluminatedWordText', { underline = true })
                vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { underline = true })
                vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { underline = true, bold = true })
            end,
        })

        -- default configuration
        require('illuminate').configure {
            -- providers: provider used to get references in the buffer, ordered by priority
            providers = {
                'lsp',
                'treesitter',
                'regex',
            },
            -- delay: delay in milliseconds
            delay = 100,
            -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
            filetypes_denylist = {
                'dirvish',
                'fugitive',
            },
            -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
            -- See `:help mode()` for possible values
            modes_denylist = { 'i', 't', 'nt', 'ntT' },
        }
    end,
}
