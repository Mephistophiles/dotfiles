local clangd = {
    'clangd',
    function()
        return {
            cmd = {
                -- see clangd --help-hidden
                'clangd',
                '--background-index',
                -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
                -- to add more checks, create .clang-tidy file in the root directory
                -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
                '--clang-tidy',
                '--completion-style=bundled',
                '--cross-file-rename',
                '--header-insertion=iwyu',
            },
            capabilities = { offsetEncoding = { 'utf-16' } },
        }
    end,
}

local supported_languages = {
    c = clangd,
    cpp = clangd,
    go = {
        'gopls',
    },
    json = {
        'jsonls',
        function()
            local exe_resolve = function(name)
                if vim.fn.exepath(name) then
                    return name
                end
            end
            return {
                cmd = { exe_resolve 'vscode-json-languageserver' or 'vscode-json-language-server', '--stdio' },
            }
        end,
    },
    nix = {
        'rnix',
        'nixd',
    },
    lua = {
        'lua_ls',
        function()
            return {
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file('', true),
                            -- Disable busted asks
                            checkThirdParty = false,
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
    },
    python = {
        'pylsp',
        function()
            return {
                settings = {
                    pylsp = {
                        plugins = {
                            pylint = {
                                enabled = true,
                            },
                        },
                    },
                },
            }
        end,
        'pyright',
    },
}

local event_pattern = vim.tbl_map(function(ft)
    return 'FileType ' .. ft
end, vim.tbl_keys(supported_languages))

return {
    {
        -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        event = event_pattern,
        name = 'lspconfig',
        config = function()
            vim.lsp.set_log_level 'off'
            local lsp_config = require 'lspconfig'
            local lsp_utils = require 'plugins.utils.lsp'

            for lang, configs in pairs(supported_languages) do
                local lsp_servers = {}
                local current_server = nil

                for _, item in ipairs(configs) do
                    if type(item) == 'string' then
                        current_server = item
                        lsp_servers[current_server] = {}
                    elseif type(item) == 'function' then
                        lsp_servers[assert(current_server)] = item()
                    elseif type(item) == 'table' then
                        lsp_servers[assert(current_server)] = item
                    else
                        error('Invalid type: ' .. string(item) .. ' for lang ' .. lang)
                    end
                end

                for server, config in pairs(lsp_servers) do
                    lsp_config[server].setup(lsp_utils.make_default_opts(config))
                end

                vim.diagnostic.config {
                    severity_sort = true,
                    signs = true,
                    update_in_insert = true,
                    underline = true,
                }
            end
        end,
    },
    {
        'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        keys = {
            {
                '<leader>ll',
                function()
                    require('lsp_lines').toggle()
                end,
                desc = 'LspLines: toggle',
            },
        },
        config = function()
            require('lsp_lines').setup()
        end,
    },
    {
        'doums/suit.nvim',
        opts = {},
        event = 'VeryLazy',
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
                fmt_on_save = false,
                -- Use lsp if no formatter was defined for this filetype
                lsp_as_default_formatter = false,
            }
        end,
    },
    {
        -- Tools for better development in rust using neovim's builtin lsp
        'simrat39/rust-tools.nvim',
        event = { 'BufRead *.rs', 'BufWinEnter *.rs', 'BufNewFile *.rs' },
        dependencies = { 'neovim/nvim-lspconfig', name = 'lspconfig' },
        config = function()
            local server = vim.tbl_deep_extend('force', require('plugins.utils.lsp').make_default_opts(), {
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
    {
        -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        opts = {},
    },
}
