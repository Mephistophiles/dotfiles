local M = {}

function M.setup() end

function M.config()
    local builtin = require 'el.builtin'
    local diagnostic = require 'el.diagnostic'
    local extensions = require 'el.extensions'
    local lsp_statusline = require 'el.plugins.lsp_status'
    local sections = require 'el.sections'
    local subscribe = require 'el.subscribe'

    local sep_left = ' ❯ '
    local sep_right = ' ❮ '

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