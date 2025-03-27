return {
    'stevearc/overseer.nvim',
    keys = {
        {
            '<F5>',
            CMD 'OverseerRestartLast',
            mode = { 'n' },
            desc = 'Overseer: run last action',
        },
        {
            '<F6>',
            CMD 'OverseerToggle',
            mode = { 'n' },
            desc = 'Overseer: toggle',
        },
    },
    opts = {
        templates = { 'builtin' },
    },
    init = function()
        vim.api.nvim_create_user_command('RunLast', function()
            local overseer = require 'overseer'
            local tasks = overseer.list_tasks { recent_first = true }
            if vim.tbl_isempty(tasks) then
                vim.notify('No tasks found', vim.log.levels.WARN)
            else
                overseer.run_action(tasks[1], 'restart')
            end
        end, {
            desc = 'Overseer: restart last action',
        })
        vim.api.nvim_create_user_command('Run', function(params)
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
            desc = 'Overseer: Run your command as an Overseer task',
            nargs = '*',
            bang = true,
        })
    end,
}
