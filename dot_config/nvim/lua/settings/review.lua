local M = {}

--- create a new quick fix item
--- @class QFItem
--- @field bufnr number
--- @field type 'E' | 'W' | 'I' | 'N' type of note
--- @field text string - text of note
--- @field lnum number - line number for start of note
--- @field end_lnum number - end of line for end of note
--- @field col number - column number for start of note
--- @field end_col number - column number for end of note
---
---@param bufnr number number of the buffer
---@param type 'E' | 'W' | 'I' | 'N' type of note
---@param text string text of note
---@return QFItem
function M.create_qfitem(bufnr, type, text)
    local start_pos = vim.api.nvim_buf_get_mark(0, [[<]])
    local end_pos = vim.api.nvim_buf_get_mark(0, [[>]])

    return {
        bufnr = bufnr,
        type = type,
        text = text,
        lnum = start_pos[1],
        end_lnum = end_pos[1],
        col = start_pos[2] + 1,
        end_col = end_pos[2] + 2,
    }
end

function M.append_note()
    vim.ui.select({ 'E', 'W', 'I', 'N' }, { prompt = 'Select note level' }, function(choice)
        vim.ui.input({ prompt = 'Enter note' }, function(input)
            local bufnr = vim.api.nvim_get_current_buf()
            local item = M.create_qfitem(bufnr, choice, input)
            local qflist = vim.fn.getqflist()

            table.insert(qflist, item)
            vim.fn.setqflist(qflist)

            vim.cmd 'cw'
        end)
    end)
end

---
---@param item QFItem
local function dump_qfitem_to_string(item)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ':~:.')
    local error_mapping = {
        E = 'error',
        W = 'warning',
        I = 'info',
        N = 'note',
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
        column_range = tostring(item.col) .. '-' .. tostring(item.end_col)
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

--- @return QFItem
local function load_qfitem_from_string(s)
    local error_mapping = {
        error = 'E',
        warning = 'W',
        info = 'I',
        note = 'N',
    }

    local filename, line_info, text = table.unpack(vim.split(s, '|'))
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
        lnum = tonumber(line_start),
        end_lnum = tonumber(line_end),
        col = tonumber(column_start),
        end_col = tonumber(column_end),
        type = error_mapping[type],
        text = text,
    }
end

function M.dump_to_file()
    vim.ui.input(
        { default = 'code-review.txt', complete = '-complete=file_in_path', prompt = 'Select file name to dump' },
        function(input)
            if vim.fn.filereadable(input) == '1' then
                vim.notify('Failed to save file to ' .. input .. '. File exists!', vim.log.levels.ERROR)
                return
            end

            local items = vim.fn.getqflist()
            local file = io.open(input, 'w')

            if not file then
                vim.notify('Failed to save file to ' .. input .. '.', vim.log.levels.ERROR)
                return
            end

            for _, item in ipairs(items) do
                file:write(dump_qfitem_to_string(item))
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
                local item = load_qfitem_from_string(line)
                print(vim.inspect(item))
                table.insert(items, item)
            end

            vim.fn.setqflist(items)
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
