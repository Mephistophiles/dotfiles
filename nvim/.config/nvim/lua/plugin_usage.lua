-- Counts configured entry points, not plugin loads or arbitrary Lua API calls.
local M = {}
local catalog, commands = {}, {}
local session, directory, session_file, timer
local dirty, warned = false, false
local config_lua = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))

local function entry(name)
    catalog[name] = catalog[name] or { manual = false, automatic = false, dependency = false }
    return catalog[name]
end

local function warn(message)
    if not warned then
        warned = true
        vim.schedule(function() vim.notify('PluginUsage: ' .. message, vim.log.levels.WARN) end)
    end
end

function M.flush()
    if not session or not dirty then
        return
    end
    local ok, err = pcall(function()
        vim.fn.mkdir(directory, 'p', '0700')
        local temporary = session_file .. '.tmp'
        assert(vim.fn.writefile({ vim.json.encode(session) }, temporary) == 0)
        assert(vim.uv.fs_rename(temporary, session_file))
    end)
    if ok then
        dirty = false
    else
        warn('could not save statistics: ' .. tostring(err))
    end
end

---@param name string Plugin name as shown by zpack
---@param action string Stable action label; never include filenames or command arguments
---@param kind? 'manual'|'automatic'
function M.record(name, action, kind)
    if not session then
        return
    end
    kind = kind or 'manual'
    entry(name)[kind] = true
    local plugin = session.plugins[name] or { manual = 0, automatic = 0, last = 0, actions = {} }
    session.plugins[name] = plugin
    plugin[kind] = plugin[kind] + 1
    plugin.last = os.time()
    plugin.actions[action] = (plugin.actions[action] or 0) + 1
    dirty = true
    -- Flush periodically while editing, and synchronously on exit. One file per
    -- process avoids read/merge/write races between concurrent editor sessions.
    if timer and not timer:is_active() then
        timer:start(2000, 0, vim.schedule_wrap(M.flush))
    end
end

function M.track_command(line, aborted)
    if aborted then
        return
    end
    -- Parse without executing. Arguments are never persisted. Unsupported or
    -- invalid commands are ignored; count explicit invocations, not success.
    local ok, parsed = pcall(vim.api.nvim_parse_cmd, line, {})
    if ok then
        if commands[parsed.cmd] then
            M.record(commands[parsed.cmd], ':' .. parsed.cmd)
        end
        if parsed.nextcmd and parsed.nextcmd ~= '' then
            M.track_command(parsed.nextcmd, false)
        end
    end
end

local function instrument(spec, dependency)
    if type(spec) == 'string' then
        spec = { spec }
    end
    if type(spec) ~= 'table' or type(spec[1]) ~= 'string' then
        return spec
    end
    local name = spec.name or spec[1]:gsub('/$', ''):match('[^/]+$'):gsub('%.git$', '')
    local info = entry(name)
    if dependency then
        info.dependency = true
    else
        info.direct = true
    end
    local cmds = type(spec.cmd) == 'string' and { spec.cmd } or spec.cmd
    if type(cmds) == 'table' then
        for _, cmd in ipairs(cmds) do
            commands[cmd] = name
            info.manual = true
        end
    end
    if type(spec.keys) == 'table' then
        for _, key in ipairs(spec.keys) do
            if type(key) == 'table' then
                local rhs = key[2]
                local action = 'key ' .. key[1]
                if type(rhs) == 'function' then
                    key[2] = function(...)
                        M.record(name, action)
                        return rhs(...)
                    end
                    info.manual = true
                elseif type(rhs) == 'string' and rhs ~= '' and rhs:lower() ~= '<nop>' and not key.expr then
                    -- Keep string mappings as strings: converting them to Lua
                    -- callbacks changes operator-pending and visual behavior.
                    key[2] = ('<Cmd>lua require("plugin_usage").record(%q, %q)<CR>'):format(name, action) .. rhs
                    info.manual = true
                end
            end
        end
    end
    if spec.dependencies then
        local dependencies = type(spec.dependencies) == 'string' and { spec.dependencies } or spec.dependencies
        for i, dep in ipairs(dependencies) do
            dependencies[i] = instrument(dep, true)
        end
        spec.dependencies = dependencies
    end
    return spec
end

-- Use the public spec interface, without patching zpack or Neovim APIs.
function M.specs()
    local result = {}
    for _, path in ipairs(vim.fn.glob(config_lua .. '/plugins/*.lua', false, true)) do
        local name = vim.fs.basename(path):gsub('%.lua$', '')
        local spec = vim.deepcopy(require('plugins.' .. name))
        if type(spec[1]) == 'table' then
            for _, item in ipairs(spec) do
                result[#result + 1] = instrument(item, false)
            end
        else
            result[#result + 1] = instrument(spec, false)
        end
    end
    -- Explicit hooks below and in the corresponding config modules.
    for _, name in ipairs { 'nvim-treesitter', 'gitsigns.nvim', 'nvim-lint', 'conform.nvim' } do
        entry(name).automatic = true
    end
    entry('conform.nvim').manual = true
    entry('gitsigns.nvim').manual = true
    for _, cmd in ipairs { 'Run', 'Make', 'Just' } do
        commands[cmd] = 'compile-mode.nvim'
    end
    commands.Snacks = 'snacks.nvim'
    return result
end

local function valid_session(data)
    if type(data) ~= 'table' or data.version ~= 1 or type(data.plugins) ~= 'table'
        or type(data.started) ~= 'number'
    then
        return false
    end
    for name, plugin in pairs(data.plugins) do
        if type(name) ~= 'string' or type(plugin) ~= 'table' then
            return false
        end
        for _, field in ipairs { 'manual', 'automatic', 'last' } do
            if type(plugin[field]) ~= 'number' or plugin[field] < 0 then
                return false
            end
        end
        if type(plugin.actions) ~= 'table' then
            return false
        end
        for action, count in pairs(plugin.actions) do
            if type(action) ~= 'string' or type(count) ~= 'number' or count < 0 then
                return false
            end
        end
    end
    return true
end

function M.summary()
    M.flush()
    local rows, sessions, skipped = {}, 0, 0
    local function row(name)
        rows[name] = rows[name] or { name = name, manual = 0, automatic = 0, sessions = 0, last = 0, actions = {} }
        return rows[name]
    end
    for name in pairs(catalog) do
        row(name)
    end
    for _, path in ipairs(vim.fn.glob(directory .. '/*.json', false, true)) do
        local ok, data = pcall(function()
            return vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
        end)
        if ok and valid_session(data) then
            sessions = sessions + 1
            for name, plugin in pairs(data.plugins) do
                local item = row(name)
                item.manual = item.manual + plugin.manual
                item.automatic = item.automatic + plugin.automatic
                item.sessions = item.sessions + 1
                item.last = math.max(item.last, plugin.last)
                for action, count in pairs(plugin.actions) do
                    item.actions[action] = (item.actions[action] or 0) + count
                end
            end
        else
            skipped = skipped + 1
        end
    end
    for name, item in pairs(rows) do
        local info = catalog[name]
        item.manual_tracked = (info and info.manual) or item.manual > 0
        item.automatic_tracked = (info and info.automatic) or item.automatic > 0
        item.coverage = not info and 'removed'
            or info.dependency and not info.direct and 'dependency'
            or info.manual and info.automatic and 'keys/cmds + auto'
            or info.manual and 'keys/cmds'
            or info.automatic and 'automatic'
            or 'not tracked'
    end
    return { plugins = rows, sessions = sessions, skipped = skipped }
end

function M.show(sort)
    sort = sort == '' and 'count' or sort or 'count'
    local data = M.summary()
    local rows = vim.tbl_values(data.plugins)
    table.sort(rows, function(a, b)
        if sort == 'recent' and a.last ~= b.last then
            return a.last > b.last
        elseif sort == 'count' and a.manual + a.automatic ~= b.manual + b.automatic then
            return a.manual + a.automatic > b.manual + b.automatic
        end
        return a.name < b.name
    end)
    local lines = {
        ('Plugin usage — %d sessions'):format(data.sessions),
        'Invocations through configured keys and typed Ex commands; automatic = requests/attachments.',
        'Not tracked is not zero usage. Dependencies may be needed by other plugins.',
        'Direct Lua calls, plugin-internal mappings and nil-RHS lazy mappings are not counted.',
        'Commands: :PluginUsage [count|recent|name]   Enter: action details   q: close',
        'Data: ' .. directory,
        '',
        ('%-30s %8s %8s %8s %-19s %s'):format('Plugin', 'Manual', 'Auto', 'Sessions', 'Last used', 'Coverage'),
    }
    if data.skipped > 0 then
        table.insert(lines, ('Skipped %d invalid session files.'):format(data.skipped))
    end
    local row_names = {}
    for _, item in ipairs(rows) do
        lines[#lines + 1] = ('%-30s %8s %8s %8d %-19s %s'):format(
            item.name, item.manual_tracked and item.manual or '-',
            item.automatic_tracked and item.automatic or '-', item.sessions,
            item.last == 0 and '-' or os.date('%Y-%m-%d %H:%M', item.last), item.coverage
        )
        row_names[#lines] = item.name
    end
    vim.cmd 'botright new'
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = 'pluginusage'
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.wo.wrap = false
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, nowait = true })
    vim.keymap.set('n', '<CR>', function()
        local name = row_names[vim.api.nvim_win_get_cursor(0)[1]]
        if not name then
            return
        end
        local details = { name }
        for _, action in ipairs(vim.fn.sort(vim.tbl_keys(data.plugins[name].actions))) do
            details[#details + 1] = ('%6d  %s'):format(data.plugins[name].actions[action], action)
        end
        if #details == 1 then
            details[#details + 1] = 'No recorded actions.'
        end
        vim.api.nvim_echo({ { table.concat(details, '\n') } }, true, {})
    end, { buffer = buf, desc = 'Show recorded actions' })
end

function M.setup(opts)
    if session then
        return
    end
    opts = opts or {}
    directory = opts.directory or vim.fs.joinpath(vim.fn.stdpath 'state', 'plugin-usage')
    session_file = vim.fs.joinpath(directory, ('%d-%d-%.0f.json'):format(os.time(), vim.fn.getpid(), vim.uv.hrtime()))
    session = { version = 1, started = os.time(), plugins = {} }
    dirty = true
    timer = vim.uv.new_timer()
    if timer then
        timer:unref()
    end
    local group = vim.api.nvim_create_augroup('PluginUsage', { clear = true })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = group,
        pattern = ':',
        callback = function()
            M.track_command(vim.fn.getcmdline(), vim.v.event.abort)
        end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
            if timer then
                timer:stop()
                timer:close()
            end
            M.flush()
        end,
    })
    vim.api.nvim_create_user_command('PluginUsage', function(args) M.show(args.args) end, {
        nargs = '?',
        complete = function() return { 'count', 'recent', 'name' } end,
        desc = 'Show persistent plugin usage statistics',
    })
end

return M
