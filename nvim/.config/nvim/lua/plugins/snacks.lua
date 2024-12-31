local augroup = vim.api.nvim_create_augroup('Snacks', { clear = true })

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd('LspProgress', {
    group = augroup,
    ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= 'table' then
            return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
            if i == #p + 1 or p[i].token == ev.data.params.token then
                p[i] = {
                    token = ev.data.params.token,
                    msg = ('[%3d%%] %s%s'):format(
                        value.kind == 'end' and 100 or value.percentage or 100,
                        value.title or '',
                        value.message and (' **%s**'):format(value.message) or ''
                    ),
                    done = value.kind == 'end',
                }
                break
            end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
            return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
        vim.notify(table.concat(msg, '\n'), 'info', {
            id = 'lsp_progress',
            title = client.name,
            opts = function(notif)
                notif.ft = 'markdown'
                notif.icon = #progress[client.id] == 0 and ' '
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})

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
        notifier = {},
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
    end,
}
