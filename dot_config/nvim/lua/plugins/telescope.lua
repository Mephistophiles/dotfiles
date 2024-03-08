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
        { '<leader>su', CMD 'Telescope undo', { desc = '[S]how [U]ndo history' } },
        {
            '<leader>sh',
            function()
                require('telescope.builtin').help_tags()
            end,
            { desc = '[S]earch [H]elp' },
        },
        {
            '<leader>sk',
            function()
                require('telescope.builtin').keymaps()
            end,
            { desc = '[S]earch [K]eymaps' },
        },
        {
            '<leader>sf',
            function()
                require('telescope.builtin').find_files()
            end,
            { desc = '[S]earch [F]iles' },
        },
        {
            '<leader>ss',
            function()
                require('telescope.builtin').builtin()
            end,
            { desc = '[S]earch [S]elect Telescope' },
        },
        {
            '<leader>sw',
            function()
                require('telescope.builtin').grep_string()
            end,
            { desc = '[S]earch current [W]ord' },
        },
        {
            '<leader>sg',
            function()
                require('telescope.builtin').live_grep()
            end,
            { desc = '[S]earch by [G]rep' },
        },
        {
            '<leader>sd',
            function()
                require('telescope.builtin').diagnostics()
            end,
            { desc = '[S]earch [D]iagnostics' },
        },
        {
            '<leader>sr',
            function()
                require('telescope.builtin').resume()
            end,
            { desc = '[S]earch [R]esume' },
        },
        {
            '<leader>s.',
            function()
                require('telescope.builtin').oldfiles()
            end,
            { desc = '[S]earch Recent Files ("." for repeat)' },
        },
        {
            '<leader>sb',
            function()
                require('telescope.builtin').buffers()
            end,
            { desc = '[S]earch existing [B]uffers' },
        },
        {
            '<leader>s/',
            function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end,
            { desc = '[/] Fuzzily [S]earch in current buffer' },
        },
        {
            '<leader>sn',
            function()
                require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
            end,
            { desc = '[S]earch [N]eovim files' },
        },
    },
    config = function()
        local actions = require 'telescope.actions'
        require('telescope').setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-Down>'] = actions.cycle_history_next,
                        ['<C-Up>'] = actions.cycle_history_prev,
                        ['<C-u>'] = false,
                        ['<C-space>'] = actions.to_fuzzy_refine,
                    },
                },
            },
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
