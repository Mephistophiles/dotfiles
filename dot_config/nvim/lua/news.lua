local news_file_path = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1]
local data_dir = vim.fn.stdpath 'data'
local prev_file_path = data_dir .. '/news.txt.prev'

local function notify(msg, level, opts)
    vim.notify(msg, level, vim.tbl_extend('force', { title = 'News' }, opts or {}))
end

local function hash_file(file_path)
    return vim.fn.sha256(io.open(file_path, 'r'):read '*a')
end

local hash = hash_file(news_file_path)
if vim.uv.fs_access(prev_file_path, 'R') then
    local prev_hash = hash_file(prev_file_path)
    if prev_hash ~= hash then
        notify 'news.txt was updated'
    end
else
    vim.uv.fs_copyfile(news_file_path, prev_file_path, function() end)
end

vim.api.nvim_create_user_command('News', function(ctx)
    if #ctx.fargs == 0 then
        local prev_hash = hash_file(prev_file_path)
        if prev_hash == hash then
            notify('No changes to news.txt', vim.log.levels.ERROR)
            return
        end
        vim.cmd(('tabnew | edit %s | diffthis | vsplit %s | diffthis'):format(prev_file_path, news_file_path))
        return
    end
    if ctx.fargs[1] == 'apply' then
        vim.uv.fs_copyfile(news_file_path, prev_file_path, function() end)
        return
    end
    notify('Unknown args: ' .. ctx.args, vim.log.levels.ERROR)
end, {
    desc = 'View updates to news.txt',
    nargs = '?',
    complete = function()
        return { 'apply' }
    end,
})
