local size_limit = 1.5 * 1024 * 1024
local average_line_limit = 1000
local group = vim.api.nvim_create_augroup('ConfigBigfile', { clear = true })

-- Run before filetype detection, LSP and plugin FileType handlers.
vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    callback = function(args)
        local stat = vim.uv.fs_stat(args.file)
        vim.b[args.buf].bigfile = stat ~= nil and stat.size > size_limit
    end,
})

vim.filetype.add {
    pattern = {
        ['.*'] = {
            function(_, buf)
                if not buf or vim.bo[buf].buftype ~= '' then
                    return
                end
                local lines = vim.api.nvim_buf_line_count(buf)
                local bytes = vim.api.nvim_buf_get_offset(buf, lines)
                if vim.b[buf].bigfile or (bytes - lines) / lines > average_line_limit then
                    vim.b[buf].bigfile = true
                    return 'bigfile'
                end
            end,
            { priority = math.huge },
        },
    },
}

local function setup_window(win)
    vim.wo[win].foldmethod = 'manual'
    vim.wo[win].foldexpr = '0'
    vim.wo[win].wrap = false
    vim.wo[win].cursorline = false
    vim.wo[win].cursorcolumn = false
    vim.wo[win].colorcolumn = ''
end

vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'bigfile',
    callback = function(args)
        vim.b[args.buf].bigfile = true
        vim.b[args.buf].snacks_indent = false
        vim.b[args.buf].format_on_save = false
        vim.bo[args.buf].syntax = ''
        vim.bo[args.buf].indentexpr = ''
        vim.diagnostic.enable(false, { bufnr = args.buf })
        for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            setup_window(win)
        end
    end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(args)
        if vim.b[args.buf].bigfile then
            for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
                setup_window(win)
            end
        end
    end,
})
