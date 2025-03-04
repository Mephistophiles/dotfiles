return {
    'stevearc/overseer.nvim',
    keys = {
        {
            '<F5>',
            CMD 'OverseerRestartLast',
            mode = { 'n' },
            desc = 'Compile Mode: run compile',
        },
    },
    opts = {
        templates = { 'builtin' },
    },
    init = function()
        vim.api.nvim_create_user_command('OverseerRestartLast', function()
            local overseer = require 'overseer'
            local tasks = overseer.list_tasks { recent_first = true }
            if vim.tbl_isempty(tasks) then
                vim.notify('No tasks found', vim.log.levels.WARN)
            else
                overseer.run_action(tasks[1], 'restart')
            end
        end, {})
        vim.api.nvim_create_user_command('Compile', function(params)
            -- Insert args at the '$*' in the makeprg
            local task = require('overseer').new_task {
                cmd = vim.fn.expandcmd(params.args),
                components = {
                    { 'on_output_quickfix', open = not params.bang, open_height = 8 },
                    'default',
                },
            }
            task:start()
        end, {
            desc = 'Run your makeprg as an Overseer task',
            nargs = '*',
            bang = true,
        })
        vim.api.nvim_create_user_command('Make', function(params)
            -- Insert args at the '$*' in the makeprg
            local cmd, num_subs = vim.o.makeprg:gsub('%$%*', params.args)
            if num_subs == 0 then
                cmd = cmd .. ' ' .. params.args
            end
            local task = require('overseer').new_task {
                cmd = vim.fn.expandcmd(cmd),
                components = {
                    { 'on_output_quickfix', open = not params.bang, open_height = 8 },
                    'default',
                },
            }
            task:start()
        end, {
            desc = 'Run your makeprg as an Overseer task',
            nargs = '*',
            bang = true,
        })
    end,
}
