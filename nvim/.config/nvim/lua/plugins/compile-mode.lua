return {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile', 'Recompile' },
    ref = 'latest',
    keys = {
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
        vim.api.nvim_create_user_command('Run', function(params)
            run_task(params)
        end, {
            desc = 'Compile-Mode: run compile task',
            nargs = '*',
            bang = true,
        })
        vim.api.nvim_create_user_command('Make', function(params)
            run_task(params, 'make')
        end, {
            desc = 'Compile-Mode: run make target',
            nargs = '*',
            bang = true,
        })
        vim.api.nvim_create_user_command('Just', function(params)
            run_task(params, 'just')
        end, {
            desc = 'Compile_mode: run justfile target',
            nargs = '*',
            bang = true,
        })
    end,
}
