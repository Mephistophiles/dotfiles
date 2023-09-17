return {
    { -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        lazy = true,
        name = 'lspconfig',
        config = function()
            vim.lsp.set_log_level 'off'
        end,
    },
    {
        'nvimdev/guard.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            'nvimdev/guard-collection',
        },
        config = function()
            local ft = require 'guard.filetype'
            local diag_fmt = require('guard.lint').diag_fmt

            local clang_analyzer = function()
                return {
                    cmd = 'clang-analyzer',
                    args = {},
                    stdin = false,
                    output_fmt = function(result, buf)
                        local map = {
                            'error',
                            'warning',
                            'information',
                            'hint',
                            'note',
                        }

                        local messages = vim.split(result, '\n')
                        local diags = {}
                        vim.tbl_map(function(mes)
                            local message
                            local severity
                            for idx, t in ipairs(map) do
                                local _, p = mes:find(t)
                                if p then
                                    message = mes:sub(p + 2, #mes)
                                    severity = idx
                                    local pos = mes:match [[(%d+:%d+)]]
                                    local lnum, col = unpack(vim.split(pos, ':'))
                                    diags[#diags + 1] = diag_fmt(
                                        buf,
                                        tonumber(lnum) - 1,
                                        tonumber(col),
                                        message,
                                        severity > 4 and 4 or severity,
                                        'clang-analyzer'
                                    )
                                end
                            end
                        end, messages)

                        return diags
                    end,
                }
            end

            ft('c,cpp'):fmt({ cmd = 'clang-format', stdin = true, find = '.clang-format' }):lint(clang_analyzer())
            ft('go'):fmt 'gofmt'
            ft('python'):fmt 'lsp'
            ft('rust'):fmt 'rustfmt'
            ft('json'):fmt {
                cmd = 'jq --indent 4',
                stdin = true,
            }
            ft('lua'):fmt { cmd = 'stylua', args = { '--search-parent-directories', '-' }, stdin = true }
            ft('sh,bash'):lint 'shellcheck'

            -- Call setup() LAST!
            require('guard').setup {
                -- the only options for the setup function
                fmt_on_save = true,
                -- Use lsp if no formatter was defined for this filetype
                lsp_as_default_formatter = false,
            }
        end,
    },
    { -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        event = { 'BufRead *.rs', 'BufWinEnter *.rs', 'BufNewFile *.rs' },
        dependencies = { 'neovim/nvim-lspconfig', name = 'lspconfig' },
        config = function()
            local server = vim.tbl_deep_extend('force', require('utils.lsp').make_default_opts(), {
                flags = { allow_incremental_sync = true },
                settings = {
                    ['rust-analyzer'] = {
                        assist = { importGranularity = 'module', importPrefix = 'by_self' },
                        cargo = { loadOutDirsFromCheck = true, allFeatures = true },
                        procMacro = { enable = true },
                        checkOnSave = { command = 'clippy' },
                        experimental = { procAttrMacros = true },
                        lens = { methodReferences = true, references = true },
                    },
                },
            })

            local dap = {
                adapter = {
                    type = 'executable',
                    name = 'lldb',
                },
            }

            local opts = { server = server, dap = dap }

            require('rust-tools').setup(opts)
        end,
    },
    { -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        opts = {},
    },
}
