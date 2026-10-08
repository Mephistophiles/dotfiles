local namespace = vim.api.nvim_create_namespace 'config.trailing_whitespace'
local disabled = { diff = true, git = true, gitcommit = true, patch = true, strace = true, bigfile = true }
local group = vim.api.nvim_create_augroup('ConfigTrailingWhitespace', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'FileType' }, {
    group = group,
    callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= '' or vim.b[buf].bigfile or disabled[vim.bo[buf].filetype] then
            vim.diagnostic.reset(namespace, buf)
            return
        end

        local diagnostics = {}
        for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            local first, last = line:find '[ \t]+$'
            if first then
                diagnostics[#diagnostics + 1] = {
                    lnum = row - 1,
                    end_lnum = row - 1,
                    col = first - 1,
                    end_col = last,
                    severity = vim.diagnostic.severity.WARN,
                    message = 'trailing whitespace',
                    source = 'trail-space',
                }
            end
        end
        vim.diagnostic.set(namespace, buf, diagnostics)
    end,
})
