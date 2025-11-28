return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        explorer = { enabled = true },
        indent = { enabled = true },
        picker = {
            enabled = true,
            layout = { preset = 'ivy', layout = { position = 'bottom' } },
            sources = {
                explorer = {
                    hidden = true,
                    ignored = true,
                    layout = { layout = { position = 'left' } },
                    win = {
                        list = {
                            keys = {
                                ['<Esc>'] = function()
                                    --Do nothing
                                end,
                            },
                        },
                    },
                },
            },
        },
        terminal = { enabled = true },
    },
    keys = {
        {
            '<leader>N',
            desc = 'Snacks: Neovim News',
            function()
                Snacks.win {
                    file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
                    width = 0.6,
                    height = 0.6,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = 'yes',
                        statuscolumn = ' ',
                        conceallevel = 3,
                    },
                }
            end,
        },
        {
            '<leader><leader>',
            function()
                Snacks.picker.smart()
            end,
            desc = 'Snacks: Smart Find Files',
        },
        {
            '<leader>sf',
            function()
                Snacks.picker.files()
            end,
            desc = 'Snacks: Find Files',
        },
        {
            '<leader>sb',
            function()
                Snacks.picker.buffers()
            end,
            desc = 'Snacks: buffers',
        },
        {
            '<leader>sw',
            function()
                Snacks.picker.grep_word()
            end,
            desc = 'Snacks: Visual selection or word',
            mode = { 'n', 'x' },
        },
        {
            '<leader>sg',
            function()
                Snacks.picker.grep()
            end,
            desc = 'Snacks: Grep',
        },
        {
            '<leader>sl',
            function()
                Snacks.picker.lines()
            end,
            desc = 'Snacks: Buffer Lines',
        },
        {
            '<leader>sc',
            function()
                Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
            end,
            desc = 'Snacks: Find Config File',
        },
        {
            '<leader>sk',
            function()
                Snacks.picker.keymaps()
            end,
            desc = 'Snacks: Keymaps',
        },
        {
            '<leader>su',
            function()
                Snacks.picker.undo()
            end,
            desc = 'Snacks: Undo History',
        },
        {
            '<leader>sh',
            function()
                Snacks.picker.help()
            end,
            desc = 'Snacks: Help',
        },
        {
            '<leader>sn',
            function()
                if Snacks.config.picker and Snacks.config.picker.enabled then
                    Snacks.picker.notifications()
                else
                    Snacks.notifier.show_history()
                end
            end,
            desc = 'Snacks: Show Notifications',
        },
        {
            '<leader>se',
            function()
                Snacks.picker.explorer()
            end,
            desc = 'Snacks: Explorer',
        },
        {
            '<leader>su',
            function()
                Snacks.terminal.toggle()
            end,
            desc = 'Snacks: Terminal',
        },
    },
    init = function()
        vim.api.nvim_create_autocmd('User', {
            pattern = 'VeryLazy',
            callback = function()
                local function cmd(name, fn, desc)
                    vim.api.nvim_create_user_command(name, fn, { desc = desc })
                end

                cmd('SnacksProfiler', function()
                    Snacks.profiler.pick()
                end, 'Snacks: show profiler')

                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command
            end,
        })
    end,
}
