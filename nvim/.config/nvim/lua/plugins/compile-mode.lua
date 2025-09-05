return {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile', 'Recompile' },
    ref = 'latest',
    keys = {
        {
            '<leader>r',
            CMD 'Recompile',
            mode = { 'n' },
            desc = 'Compile-Mode: run last action',
        },
        {
            '<F5>',
            CMD 'Recompile',
            mode = { 'n' },
            desc = 'Compile-Mode: run last action',
        },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- if you want to enable coloring of ANSI escape codes in
        -- compilation output, add:
        { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
    },
    init = function()
        ---@type CompileModeOpts
        vim.g.compile_mode = {
            -- to add ANSI escape code support, add:
            baleia_setup = true,
        }

        local function run_task(params, prepend)
            local cmd = { vim.fn.expandcmd(params.args) }

            if prepend then
                table.insert(cmd, 1, prepend)
            end

            vim.g.compile_command = table.concat(cmd, ' ')

            require('compile-mode').compile {
                args = vim.g.compile_command,
            }
        end

        local function create_cmd(cmd, prepend, task_name)
            vim.api.nvim_create_user_command(cmd, function(params)
                run_task(params, prepend)
            end, {
                desc = 'Compile-Mode: run ' .. task_name,
                nargs = '*',
                bang = true,
                complete = 'shellcmdline',
            })
        end
        create_cmd('Run', nil, 'custom command')
        create_cmd('Make', 'make', 'make target')
        create_cmd('Just', 'just', 'just target')
    end,
}
