return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        dashboard = {
            sections = {
                { section = 'keys', gap = 1, padding = 1 },
                { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
                { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
                {
                    pane = 2,
                    icon = ' ',
                    title = 'Git Status',
                    section = 'terminal',
                    enabled = function()
                        return Snacks.git.get_root() ~= nil
                    end,
                    cmd = 'git status --short --branch --renames',
                    height = 5,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                },
                { section = 'startup' },
            },
        },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        rename = { enabled = true },
        term = { enabled = true },
        words = { enabled = true },
    },
    keys = {
        {
            '<leader>ps',
            function()
                Snacks.profiler.scratch()
            end,
            desc = 'Snacks: open a scratch buffer with the profiler picker options',
        },
        {
            '<leader>ph',
            function()
                Snacks.profiler.highlight()
            end,
            desc = 'Snacks: toggle the profiler highlights',
        },
        {
            '<F12>',
            function()
                Snacks.terminal()
            end,
            desc = 'Snacks: toggle term',
        },
        {
            '<leader>-',
            function()
                Snacks.scratch()
            end,
            desc = 'Snacks: toggle Scratch Buffer',
        },
        {
            '<leader>_',
            function()
                Snacks.scratch.select()
            end,
            desc = 'Snacks: select Scratch Buffer',
        },
    },
    config = function(plugin, opts)
        require('snacks').setup(opts)

        vim.notify = Snacks.notifier
        table.insert(MAP_CLEANUPS, CMD 'lua Snacks.notifier.hide()')

        local augroup = vim.api.nvim_create_augroup('Snacks', { clear = true })

        vim.api.nvim_create_autocmd('User', {
            group = augroup,
            pattern = 'VeryLazy',
            callback = function()
                _G.DD = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.BT = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.DD
                vim.ui.input = Snacks.input

                -- dashboard

                -- don't start when opening a file
                if vim.fn.argc() > 0 then
                    return
                end

                -- skip stdin
                if vim.fn.line2byte '$' ~= -1 then
                    return
                end

                -- Handle nvim -M
                if not vim.o.modifiable then
                    return
                end

                -- profiling mode
                if vim.env.PROF then
                    return
                end

                for _, arg in pairs(vim.v.argv) do
                    -- whitelisted arguments
                    -- always open
                    if arg == '--startuptime' then
                        break
                    end

                    -- blacklisted arguments
                    -- always skip
                    if
                        arg == '-b'
                        -- commands, typically used for scripting
                        or arg == '-c'
                        or vim.startswith(arg, '+')
                        or arg == '-S'
                    then
                        return
                    end
                end

                -- show
                Snacks.dashboard()
            end,
        })
    end,
}
