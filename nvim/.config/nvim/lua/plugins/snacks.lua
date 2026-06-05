return {
    'folke/snacks.nvim',
    priority = 1000,
    event = 'VeryLazy',
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
                    layout = { preset = 'sidebar', layout = { position = 'right' } },
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
            '<leader>ss',
            function()
                Snacks.picker.pick()
            end,
            desc = 'Snacks: select picker',
        },
        {
            '<leader>sb',
            function()
                Snacks.picker.buffers()
            end,
            desc = 'Snacks: buffers',
        },
        {
            '<leader>sr',
            function()
                Snacks.picker.resume()
            end,
            desc = 'Snacks: resume',
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
            '<leader>sm',
            function()
                Snacks.picker.man()
            end,
            desc = 'Snacks: Man',
        },
        {
            '<leader>sd',
            function()
                Snacks.picker.diagnostics()
            end,
            desc = 'Snacks: diagnostics',
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
                Snacks.explorer()
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
                local function generate_complete_fn(list)
                    return function(arg_lead, cmdline, cursor_pos)
                        return vim.tbl_filter(function(item)
                            return item:find('^' .. arg_lead)
                        end, list)
                    end
                end
                local function cmd(name, fn, desc, nargs, complete)
                    local complete_fn = nil
                    if nargs > 0 then
                        complete_fn = generate_complete_fn(complete)
                    end
                    vim.api.nvim_create_user_command(name, fn, {
                        desc = desc,
                        nargs = nargs,
                        complete = complete_fn,
                    })
                end

                cmd('Snacks', function(opts)
                    if opts.args == 'profiler' then
                        Snacks.profiler.pick()
                    elseif opts.args == 'explorer' then
                        Snacks.explorer()
                    elseif opts.args == 'diagnostics' then
                        Snacks.picker.diagnostics()
                    elseif opts.args == 'terminal' then
                        Snacks.terminal.toggle()
                    else
                        vim.notify('Unsupported command ' .. vim.inspect(opts.args))
                    end
                end, 'Snacks: show profiler', 1, { 'profiler', 'explorer', 'diagnostics', 'terminal' })

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
