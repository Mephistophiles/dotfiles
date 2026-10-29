local M = {}
local bootstrapped = false
local bootstrap_changes = {}

function M.bootstrap()
    if bootstrapped then
        return
    end

    -- The first vim.pack call can install every missing lockfile entry before
    -- zpack registers its build hooks. Capture only that initial window.
    local capture = vim.api.nvim_create_autocmd('PackChanged', {
        group = vim.api.nvim_create_augroup('ConfigBootstrapBuild', { clear = true }),
        callback = function(event)
            local data = event.data
            if data.kind == 'install' or data.kind == 'update' then
                bootstrap_changes[data.spec.src] = true
            end
        end,
    })

    local ok, err = pcall(vim.pack.add, { 'https://github.com/zuqini/zpack.nvim' })
    vim.api.nvim_del_autocmd(capture)
    if not ok then
        error(err, 0)
    end
    bootstrapped = true
end

function M.setup(opts)
    M.bootstrap()
    local zpack = require 'zpack'
    zpack.setup(opts)

    if next(bootstrap_changes) == nil then
        return
    end

    -- Public command completion lists the resolved build hooks, including
    -- dependency specs and build=false overrides. Let zpack execute them.
    local command = opts and opts.cmd_name or 'ZPack'
    for _, name in ipairs(vim.fn.getcompletion(command .. ' build ', 'cmdline')) do
        local plugin = zpack.get_plugin(name)
        if plugin and bootstrap_changes[plugin.src] then
            vim.api.nvim_cmd({ cmd = command, args = { 'build', name } }, {})
        end
    end
    bootstrap_changes = {}
end

return M
