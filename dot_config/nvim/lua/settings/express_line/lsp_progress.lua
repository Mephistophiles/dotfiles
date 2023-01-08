local utils = require 'settings.express_line.utils'

local vim_closing = false
local buffers = {}
-- FIXME: cleanup lsp at close
local progress_storage = {}

local M = {}

local function register_buffer(client_key)
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = buffers[bufnr]

    if not clients then
        clients = {}
        buffers[bufnr] = clients
    end

    clients[client_key] = true
end

local function handle_bufleave(event)
    buffers[event.buf] = nil
end

local function handle_vimleave()
    vim_closing = true
end

local function handle_progress(_, msg, info)
    -- See: https://microsoft.github.io/language-server-protocol/specifications/specification-current/#progress
    if vim_closing then
        return
    end

    local task = msg.token
    local val = msg.value

    if not task then
        -- Notification missing required token??
        return
    end

    local client_key = info.client_id
    local client = vim.lsp.get_client_by_id(info.client_id)
    if not client then
        return
    end
    local client_name = client.name

    if client_name == 'null-ls' then
        return
    end

    -- Create entry if missing
    if progress_storage[client_key] == nil then
        progress_storage[client_key] = { name = client_name, percentage = nil, title = nil, message = nil }
    end
    local progress = progress_storage[client_key]

    register_buffer(client_key)

    -- Update progress state
    if val.kind == 'begin' then
        progress.title = val.title
        progress.message = 'Started'
    elseif val.kind == 'report' then
        if val.percentage then
            progress.percentage = val.percentage
        end
        if val.message then
            progress.message = val.message
        end
    elseif val.kind == 'end' then
        if progress.percentage then
            progress.percentage = 100
        end
        progress.message = 'Completed'
    end
end

function M.register()
    if vim.lsp.handlers['$/progress'] then
        local old_handler = vim.lsp.handlers['$/progress']
        vim.lsp.handlers['$/progress'] = function(...)
            old_handler(...)
            handle_progress(...)
        end
    else
        vim.lsp.handlers['$/progress'] = handle_progress
    end

    local augroup = vim.api.nvim_create_augroup('LSP_PROGRESS', { clear = true })

    vim.api.nvim_create_autocmd('BufLeave', { group = augroup, callback = handle_bufleave })
    vim.api.nvim_create_autocmd('VimLeave', { group = augroup, callback = handle_vimleave })
end

function M.format_func(separator)
    return utils.throttle_fn(function()
        local bufnr = vim.api.nvim_get_current_buf()

        if buffers[bufnr] then
            local output = {}
            local client_keys = buffers[bufnr]

            for client_key in pairs(client_keys) do
                local client = progress_storage[client_key]

                if client.message ~= 'Completed' then
                    table.insert(
                        output,
                        string.format('%s: %s %s %d%%%%', client.name, client.title, client.message, client.percentage)
                    )
                else
                    table.insert(output, client.name)
                end
            end

            if #output > 0 then
                return '[LSP] ' .. table.concat(output, ' | ') .. separator
            end
        end

        return ''
    end)
end

return M
