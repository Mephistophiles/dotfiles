return { -- Debug Adapter Protocol client implementation for Neovim
    'mfussenegger/nvim-dap',
    keys = {
        {
            '<leader>db',
            function()
                require('dap').toggle_breakpoint()
            end,
            { desc = 'DAP: toggle breakpoint in the current line' },
        },
        {
            '<leader>dB',
            function()
                require('dap').toggle_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end,
            { desc = 'DAP: toggle conditional breakpoint in the current line' },
        },
        {
            '<leader>dc',
            function()
                require('dap').continue()
            end,
            { desc = 'DAP: continue' },
        },
        {
            '<leader>ds',
            function()
                require('dap').step_over()
            end,
            { desc = 'DAP: step over' },
        },
        {
            '<leader>di',
            function()
                require('dap').step_into()
            end,
            { desc = 'DAP: step into' },
        },
        {
            '<leader>do',
            function()
                require('dap').step_out()
            end,
            { desc = 'DAP: step out' },
        },
        {
            '<leader>dr',
            function()
                require('dap').repl.open()
            end,
            { desc = 'DAP: open repl' },
        },
        {
            '<leader>dh',
            function()
                require('dap.ui.variables').hover()
            end,
            { desc = 'DAP: display hover information about the current variable' },
        },
    },
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
        'nvim-telescope/telescope-dap.nvim',
    },
    config = function()
        require('telescope').load_extension 'dap'
        local dap = require 'dap'
        local dap_ui = require 'dapui'

        local lldb_exe = 'lldb-vscode'

        dap.adapters.lldb = {
            name = 'lldb',

            type = 'executable',
            command = lldb_exe,
            env = {
                LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = 'YES',
            },
        }

        local vscode_lldp = vim.fn.exepath(lldb_exe)

        if vscode_lldp ~= nil and vscode_lldp ~= '' then
            dap.configurations.cpp = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},

                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    runInTerminal = false,
                },
            }

            dap.configurations.rust = vim.deepcopy(dap.configurations.cpp)

            dap.configurations.rust[1].initCommands = function()
                -- Find out where to look for the pretty printer Python module
                local rustc_sysroot = vim.fn.trim(vim.fn.system 'rustc --print sysroot')

                local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                local commands = {}
                local file = io.open(commands_file, 'r')
                if file then
                    for line in file:lines() do
                        table.insert(commands, line)
                    end
                    file:close()
                end
                table.insert(commands, 1, script_import)

                return commands
            end

            -- If you want to use this for rust and c, add something like this:
        end

        require('nvim-dap-virtual-text').setup()
        dap_ui.setup()

        dap.listeners.after.event_initialized['dapui_config'] = function()
            dap_ui.open()
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
            dap_ui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
            dap_ui.close()
        end
    end,
}
