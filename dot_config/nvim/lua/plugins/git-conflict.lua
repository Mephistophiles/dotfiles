return { -- A plugin to visualise and resolve merge conflicts in neovim
    'akinsho/git-conflict.nvim',
    enabled = false,
    version = '*',
    event = 'BufReadPost',
    config = function()
        require('git-conflict').setup {
            default_mappings = true,
            default_commands = true,
            disable_diagnostics = true,
            highlights = { -- They must have background color, otherwise the default color will be used
                incoming = 'Visual',
                current = 'Visual',
                ancestor = 'Visual',
            },
        }

        local augroup = vim.api.nvim_create_augroup('GitConflictAugroup', { clear = true })
        vim.api.nvim_create_autocmd('User', {
            group = augroup,
            pattern = 'GitConflictResolved',
            callback = function()
                local CURRENT_HL = 'GitConflictCurrent'
                local INCOMING_HL = 'GitConflictIncoming'
                local ANCESTOR_HL = 'GitConflictAncestor'
                local CURRENT_LABEL_HL = 'GitConflictCurrentLabel'
                local INCOMING_LABEL_HL = 'GitConflictIncomingLabel'
                local ANCESTOR_LABEL_HL = 'GitConflictAncestorLabel'
                local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })

                vim.api.nvim_set_hl(0, CURRENT_HL, { background = visual_hl.background, bold = true })
                vim.api.nvim_set_hl(0, INCOMING_HL, { background = visual_hl.background, bold = true })
                vim.api.nvim_set_hl(0, ANCESTOR_HL, { background = visual_hl.background, bold = true })
                vim.api.nvim_set_hl(0, CURRENT_LABEL_HL, { background = visual_hl.background })
                vim.api.nvim_set_hl(0, INCOMING_LABEL_HL, { background = visual_hl.background })
                vim.api.nvim_set_hl(0, ANCESTOR_LABEL_HL, { background = visual_hl.background })
            end,
        })

        vim.api.nvim_create_autocmd('User', {
            group = augroup,
            pattern = 'GitConflictDetected',
            callback = function()
                vim.opt_local.foldlevel = 999
            end,
        })
    end,
}
