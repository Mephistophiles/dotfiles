P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...)
    return require('plenary.reload').reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

TODO_OR_DIE = {
    after_date = function(year, month, day)
        local now = os.time()
        local required = os.time { year = year, month = month, day = day }

        if now > required then
            error(string.format('%04d/%02d/%02d is now in the past. Time to act on this!', year, month, day))
        end
    end,
    issue_closed = function(author, repo, issue_id)
        local cmd = string.format('gh --repo "%s/%s" issue view "%d" --json closed', author, repo, issue_id)
        local curl = io.popen(cmd, 'r')

        if not curl then
            return
        end

        local issue = vim.json.decode(curl:read '*a')
        curl:close()

        if issue and issue.closed == true then
            error(string.format('%s/%s#%d is closed. Time to act on this!', author, repo, issue_id))
        end
    end,
    pr_closed = function(author, repo, pr_id)
        local cmd = string.format('gh --repo "%s/%s" pr view "%d" --json closed', author, repo, pr_id)
        local curl = io.popen(cmd, 'r')

        if not curl then
            return
        end

        local pr = vim.json.decode(curl:read '*a')
        curl:close()

        if pr and pr.closed == true then
            error(string.format('%s/%s#%d is closed. Time to act on this!', author, repo, pr_id))
        end
    end,
}

MAP_CLEANUPS = {
    '<CMD>noh<CR>',
    '<CMD>call clearmatches()<CR>',
    '<CMD>lua vim.notify.dismiss()<CR>',
}

--- Get nvim command
---@param cmd string
---@return string
function CMD(cmd)
    return '<cmd>' .. cmd .. '<cr>'
end
