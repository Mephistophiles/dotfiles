local M = {}

function M.setup()
    vim.keymap.set('n', '<leader>db', function()
        require('dap').toggle_breakpoint()
    end, { desc = 'DAP: toggle breakpoint in the current line' })
    vim.keymap.set('n', '<leader>dB', function()
        require('dap').toggle_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'DAP: toggle conditional breakpoint in the current line' })
    vim.keymap.set('n', '<leader>dc', function()
        require('dap').continue()
    end, { desc = 'DAP: continue' })
    vim.keymap.set('n', '<leader>ds', function()
        require('dap').step_over()
    end, { desc = 'DAP: step over' })
    vim.keymap.set('n', '<leader>di', function()
        require('dap').step_into()
    end, { desc = 'DAP: step into' })
    vim.keymap.set('n', '<leader>do', function()
        require('dap').step_out()
    end, { desc = 'DAP: step out' })
    vim.keymap.set('n', '<leader>dr', function()
        require('dap').repl.open()
    end, { desc = 'DAP: open repl' })
    vim.keymap.set('n', '<leader>dh', function()
        require('dap.ui.variables').hover()
    end, { desc = 'DAP: display hover information about the current variable' })
end

function M.configurations()
    local dap = require 'dap'

    dap.adapters.lldb = {
        name = 'lldb',

        type = 'executable',
        command = 'lldb-vscode',
        env = {
            LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = 'YES',
        },
    }

    local vscode_lldp = vim.fn.exepath 'lldb-vscode'

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

        -- If you want to use this for rust and c, add something like this:
        dap.configurations.rust = dap.configurations.cpp
    end
end

function M.config()
    local dap = require 'dap'
    local dap_ui = require 'dapui'

    M.configurations()

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
end

return M
