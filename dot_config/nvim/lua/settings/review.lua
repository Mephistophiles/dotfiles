local M = {}
M.namespace = vim.api.nvim_create_namespace 'vim.lsp.review'

function M.create_diagnostic_item(bufnr, severity, message)
    local start_pos = vim.api.nvim_buf_get_mark(0, [[<]])
    local end_pos = vim.api.nvim_buf_get_mark(0, [[>]])

    return {
        bufnr = bufnr,
        severity = severity,
        message = message,
        lnum = start_pos[1] - 1,
        end_lnum = end_pos[1] - 1,
        col = start_pos[2],
        end_col = end_pos[2] + 1,
    }
end

function M.append_note()
    vim.ui.select({ 'ERROR', 'HINT', 'INFO', 'WARN' }, { prompt = 'Select note severity' }, function(choice)
        vim.ui.input({ prompt = 'Enter note' }, function(input)
            local bufnr = vim.api.nvim_get_current_buf()
            local item = M.create_diagnostic_item(bufnr, vim.diagnostic.severity[choice], input)
            local diagnostics = vim.diagnostic.get(bufnr, { namespace = M.namespace })

            table.insert(diagnostics, item)
            vim.diagnostic.set(M.namespace, bufnr, diagnostics)
        end)
    end)
end

local function dump_qflist_to_string(item)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ':~:.')
    local error_mapping = {
        E = 'error',
        N = 'hint',
        I = 'info',
        W = 'warn',
    }

    local line_range
    local column_range

    if item.lnum == item.end_lnum then
        line_range = tostring(item.lnum)
    else
        line_range = tostring(item.lnum) .. '-' .. tostring(item.end_lnum)
    end

    if item.col == item.end_col then
        column_range = tostring(item.col)
    else
        column_range = tostring(item.col) .. '-' .. tostring(item.end_col - 1)
    end

    return string.format(
        '%s|%s col %s %s|%s\n',
        filename,
        line_range,
        column_range,
        error_mapping[item.type],
        item.text
    )
end

local function load_diagnostic_from_string(s)
    local error_mapping = {
        error = vim.diagnostic.severity.ERROR,
        hint = vim.diagnostic.severity.HINT,
        info = vim.diagnostic.severity.INFO,
        warn = vim.diagnostic.severity.WARN,
    }

    local filename, line_info, message = table.unpack(vim.split(s, '|'))
    local lines, _, columns, type = table.unpack(vim.split(line_info, ' '))
    local line_start, line_end = table.unpack(vim.split(lines, '-'))
    local column_start, column_end = table.unpack(vim.split(columns, '-'))

    if not line_end then
        line_end = line_start
    end
    if not column_end then
        column_end = column_start
    end

    return {
        filename = filename,
        lnum = tonumber(line_start) - 1,
        end_lnum = tonumber(line_end) - 1,
        col = tonumber(column_start),
        end_col = tonumber(column_end),
        severity = error_mapping[type],
        message = message,
    }
end

function M.dump_to_file()
    vim.ui.input(
        { default = 'code-review.txt', complete = '-complete=file_in_path', prompt = 'Select file name to dump' },
        function(input)
            local items = vim.diagnostic.toqflist(
                vim.diagnostic.get(vim.api.nvim_get_current_buf(), { namespace = M.namespace })
            )
            local file = io.open(input, 'w')

            if not file then
                vim.notify('Failed to save file to ' .. input .. '.', vim.log.levels.ERROR)
                return
            end

            for _, item in ipairs(items) do
                file:write(dump_qflist_to_string(item))
            end

            file:close()
        end
    )
end

function M.load_from_file()
    vim.ui.input(
        { default = 'code-review.txt', complete = '-complete=file_in_path', prompt = 'Select file name to dump' },
        function(input)
            if vim.fn.filereadable(input) == '0' then
                vim.notify('Failed to load from file ' .. input .. '. File is not exists!', vim.log.levels.ERROR)
                return
            end

            local items = {}

            for line in io.lines(input) do
                local item = load_diagnostic_from_string(line)
                table.insert(items, item)
            end

            vim.diagnostic.set(M.namespace, vim.api.nvim_get_current_buf(), items)
        end
    )
end

function M.setup()
    vim.keymap.set(
        'v',
        '<leader><leader>',
        '<esc><cmd>lua require("settings.review").append_note()<cr>',
        { desc = 'Append review note to the current selection' }
    )
    vim.keymap.set(
        'n',
        '<leader>.',
        '<esc><cmd>lua require("settings.review").dump_to_file()<cr>',
        { desc = 'Store the current review to file' }
    )
    vim.keymap.set(
        'n',
        '<leader>>',
        '<esc><cmd>lua require("settings.review").load_from_file()<cr>',
        { desc = 'Load review from file' }
    )
end

return M
