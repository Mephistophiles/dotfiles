local multi_rg = function(opts)
    local conf = require('telescope.config').values
    local finders = require 'telescope.finders'
    local make_entry = require 'telescope.make_entry'
    local pickers = require 'telescope.pickers'
    local flatten = vim.tbl_flatten

    opts = opts or {}
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

    local custom_grep = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == '' then
                return nil
            end

            local prompt_split = vim.split(prompt, '  ')

            local args = { 'rg' }
            if prompt_split[1] then
                table.insert(args, '-e')
                table.insert(args, prompt_split[1])
            end

            if prompt_split[2] then
                table.insert(args, '-g')
                table.insert(args, prompt_split[2])
            end

            return flatten {
                args,
                { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
            }
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = 'Live Grep (with patterns)',
            finder = custom_grep,
            previewer = conf.grep_previewer(opts),
            sorter = require('telescope.sorters').empty(),
        })
        :find()
end
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
                require('telescope.builtin').find_files(require('telescope.themes').get_ivy {})
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
                require('telescope.builtin').grep_string(require('telescope.themes').get_ivy {})
            end,
            { desc = '[S]earch current [W]ord' },
        },
        {
            '<leader>sg',
            function()
                multi_rg(require('telescope.themes').get_ivy {})
            end,
            { desc = '[S]earch by [G]rep' },
        },
        {
            '<leader>sd',
            function()
                require('telescope.builtin').diagnostics(require('telescope.themes').get_ivy {})
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
