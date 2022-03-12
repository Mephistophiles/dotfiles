local M = {}

function M.setup()
    MAP.nnoremap('<leader>db', function()
        require('dap').toggle_breakpoint()
    end)
    MAP.nnoremap('<leader>dB', function()
        require('dap').toggle_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end)

    MAP.nnoremap('<leader>dc', function()
        require('dap').continue()
    end)
    MAP.nnoremap('<leader>ds', function()
        require('dap').step_over()
    end)
    MAP.nnoremap('<leader>di', function()
        require('dap').step_into()
    end)
    MAP.nnoremap('<leader>do', function()
        require('dap').step_out()
    end)
    MAP.nnoremap('<leader>dr', function()
        require('dap').repl.open()
    end)
    MAP.nnoremap('<leader>dh', function()
        require('dap.ui.variables').hover()
    end)
end

function M.config()
    local vscode_lldp = vim.fn.exepath 'lldb-vscode'

    if vscode_lldp == nil or vscode_lldp == '' then
        return
    end

    local dap = require 'dap'
    local dap_ui = require 'dapui'

    require('nvim-dap-virtual-text').setup()
    dap_ui.setup()

    dap.adapters.lldb = { type = 'executable', command = vscode_lldp, name = 'lldb' }

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

    dap.listeners.after.event_initialized['dapui_config'] = function()
        dap_ui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        dap_ui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        dap_ui.close()
    end

    -- If you want to use this for rust and c, add something like this:
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
end

return M
