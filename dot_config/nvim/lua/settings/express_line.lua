local sep_left = ' ❯ '
local sep_right = ' ❮ '

local LSP_PROGRESS = {
    vim_closing = false,
    buffers = {},
    -- FIXME: cleanup lsp at close
    progress = {},
}

function LSP_PROGRESS.register_buffer(client_key)
    local bufnr = vim.api.nvim_get_current_buf()

    local clients = LSP_PROGRESS.buffers[bufnr]

    if not clients then
        clients = {}
        LSP_PROGRESS.buffers[bufnr] = clients
    end

    clients[client_key] = true
end

function LSP_PROGRESS.handle_bufleave(event)
    LSP_PROGRESS.buffers[event.buf] = nil
end

function LSP_PROGRESS.handle_vimleave()
    LSP_PROGRESS.vim_closing = true
end

function LSP_PROGRESS.handle_progress(_, msg, info)
    -- See: https://microsoft.github.io/language-server-protocol/specifications/specification-current/#progress
    if LSP_PROGRESS.vim_closing then
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
    if LSP_PROGRESS.progress[client_key] == nil then
        LSP_PROGRESS.progress[client_key] = { name = client_name, percentage = nil, title = nil, message = nil }
    end
    local progress = LSP_PROGRESS.progress[client_key]

    LSP_PROGRESS.register_buffer(client_key)

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

function LSP_PROGRESS.is_installed()
    return vim.lsp.handlers['$/progress'] == LSP_PROGRESS.handle_progress
end

function LSP_PROGRESS.register()
    if vim.lsp.handlers['$/progress'] then
        local old_handler = vim.lsp.handlers['$/progress']
        vim.lsp.handlers['$/progress'] = function(...)
            old_handler(...)
            LSP_PROGRESS.handle_progress(...)
        end
    else
        vim.lsp.handlers['$/progress'] = LSP_PROGRESS.handle_progress
    end

    local augroup = vim.api.nvim_create_augroup('LSP_PROGRESS', {})

    vim.api.nvim_create_autocmd('BufLeave', { group = augroup, callback = LSP_PROGRESS.handle_bufleave })
    vim.api.nvim_create_autocmd('VimLeave', { group = augroup, callback = LSP_PROGRESS.handle_vimleave })
end

function LSP_PROGRESS.fmt()
    local bufnr = vim.api.nvim_get_current_buf()

    if LSP_PROGRESS.buffers[bufnr] then
        local output = {}
        local client_keys = LSP_PROGRESS.buffers[bufnr]

        for client_key in pairs(client_keys) do
            local client = LSP_PROGRESS.progress[client_key]

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
            return '[LSP] ' .. table.concat(output, ' | ') .. sep_right
        end
    end

    return ''
end

local M = {}

function M.config()
    LSP_PROGRESS.register()

    local builtin = require 'el.builtin'
    local diagnostic = require 'el.diagnostic'
    local extensions = require 'el.extensions'
    local lsp_statusline = require 'el.plugins.lsp_status'
    local sections = require 'el.sections'
    local subscribe = require 'el.subscribe'

    local diagnostic_formatter = function(_, _, counts)
        local items = {}

        local highlight = function(higroup, type, count)
            table.insert(items, '%#' .. higroup .. '#' .. type .. ':' .. tostring(count) .. '%*')
        end

        if counts.errors > 0 then
            highlight('DiagnosticError', 'E', counts.errors)
        end

        if counts.warnings > 0 then
            highlight('DiagnosticWarn', 'W', counts.warnings)
        end

        if counts.infos > 0 then
            highlight('DiagnosticInfo', 'I', counts.infos)
        end

        if counts.hints > 0 then
            highlight('DiagnosticHint', 'H', counts.hints)
        end

        if #items > 0 then
            table.insert(items, 1, sep_left)
        end

        return table.concat(items, ' ')
    end

    local diagnostic_display = diagnostic.make_buffer(diagnostic_formatter)
    local git_branch = subscribe.buf_autocmd('el_git_branch', 'BufEnter', function(window, buffer)
        local branch = extensions.git_branch(window, buffer)
        if branch then
            return sep_left .. extensions.git_icon() .. ' ' .. branch
        end
    end)
    local git_changes = subscribe.buf_autocmd('el_git_changes', 'BufWritePost', function(window, buffer)
        return extensions.git_changes(window, buffer)
    end)

    local show_current_func = function(window, buffer)
        if buffer.filetype == 'lua' then
            return ''
        end

        return lsp_statusline.current_function(window, buffer)
    end

    local filetype = function(_, buffer)
        local filetype = buffer.filetype
        local icon = require('nvim-web-devicons').get_icon(buffer.name, buffer.extension, { default = true })

        return icon .. ' ' .. filetype
    end

    local navic = require 'nvim-navic'

    local navic_output = function()
        if navic.is_available() then
            local location = navic.get_location()

            if #location > 0 then
                return location .. sep_right
            end
        end

        return ''
    end

    require('el').setup {
        -- An example generator can be seen in `Setup`.
        -- A default one is supplied if you do not want to customize it.
        generator = function()
            return {
                sections.left_subsection {
                    divider = sep_left,
                    items = {
                        extensions.gen_mode { format_string = ' %s ' },
                        git_branch,
                        diagnostic_display,
                    },
                },
                sections.split,
                sections.maximum_width(builtin.file_relative, 0.60),
                sections.collapse_builtin { { ' ' }, { builtin.modified_flag } },
                sections.split,
                show_current_func,
                git_changes,
                sections.collapse_builtin {
                    builtin.help_list,
                    builtin.readonly_list,
                },
                sep_right,
                navic_output,
                LSP_PROGRESS.fmt,
                sections.collapse_builtin {
                    '[',
                    builtin.line_with_width(3),
                    ':',
                    builtin.column_with_width(2),
                    ']',
                },
                sep_right,
                filetype,
            }
        end,
    }
end

return M
