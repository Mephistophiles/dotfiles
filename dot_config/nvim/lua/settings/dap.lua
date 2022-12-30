local M = {}

function M.configurations()
    local dap = require 'dap'

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
