return { -- Find, Filter, Preview, Pick. All lua, all the time.
    'nvim-telescope/telescope.nvim',
    module = 'telescope',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-telescope/telescope-project.nvim',
        'debugloop/telescope-undo.nvim',
    },
    keys = {
        { '<leader>su', CMD 'Telescope undo', desc = 'Telescope: [S]how [U]ndo history' },
        {
            '<leader>sh',
            CMD 'Telescope help_tags',
            desc = 'Telescope: [S]earch [H]elp',
        },
        {
            '<leader>sk',
            CMD 'Telescope keymaps',
            desc = 'Telescope: [S]earch [K]eymaps',
        },
        {
            '<leader>sf',
            CMD 'Telescope find_files',
            desc = 'Telescope: [S]earch [F]iles',
        },
        {
            '<leader>ss',
            CMD 'Telescope',
            desc = 'Telescope: [S]earch [S]elect Telescope',
        },
        {
            '<leader>sl',
            CMD 'Telescope lsp_document_symbols',
            desc = 'Telescope: [S]earch [L]SP document symbols',
        },
        {
            '<leader>sL',
            CMD 'Telescope lsp_workspace_symbols',
            desc = 'Telescope: [S]earch [L]SP workspace symbols',
        },
        {
            '<leader>sw',
            CMD 'Telescope grep_string',
            desc = 'Telescope: [S]earch current [W]ord',
        },
        {
            '<leader>sg',
            function()
                local multi_rg = require 'plugins.telescope.multi-rg'

                multi_rg(require('telescope.themes').get_ivy {})
            end,
            desc = 'Telescope: [S]earch by [G]rep',
        },
        {
            '<leader>sd',
            CMD 'Telescope diagnostics',
            desc = 'Telescope: [S]earch [D]iagnostics',
        },
        {
            '<leader>sr',
            CMD 'Telescope resume',
            desc = 'Telescope: [S]earch [R]esume',
        },
        {
            '<leader>s.',
            CMD 'Telescope oldfiles',
            desc = 'Telescope: [S]earch Recent Files ("." for repeat)',
        },
        {
            '<leader>sb',
            CMD 'Telescope buffers',
            desc = 'Telescope: [S]earch existing [B]uffers',
        },
        {
            '<leader>s/',
            CMD 'Telescope current_buffer_fuzzy_find',
            desc = 'Telescope: [/] Fuzzily [S]earch in current buffer',
        },
        {
            '<leader>sn',
            function()
                require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
            end,
            desc = 'Telescope: [S]earch [N]eovim files',
        },
    },
    config = function()
        local actions = require 'telescope.actions'
        require('telescope').setup {
            defaults = vim.tbl_extend(
                'force',
                require('telescope.themes').get_ivy(), -- or get_cursor, get_ivy
                {
                    mappings = {
                        i = {
                            ['<C-Down>'] = actions.cycle_history_next,
                            ['<C-Up>'] = actions.cycle_history_prev,
                            ['<C-u>'] = false,
                            ['<C-space>'] = actions.to_fuzzy_refine,
                        },
                    },
                }
            ),
            pickers = {
                buffers = {
                    mappings = {
                        i = {
                            ['<c-d>'] = actions.delete_buffer,
                        },
                        n = {
                            ['<c-d>'] = actions.delete_buffer,
                        },
                    },
                },
                current_buffer_fuzzy_find = {
                    previewer = true,
                },
            },
        }
        require('telescope').load_extension 'project'
        require('telescope').load_extension 'ui-select'
        require('telescope').load_extension 'undo'
    end,
}
