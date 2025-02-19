local clangd = {
    'clangd',
    {
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
    },
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
        'nixd',
    },
    lua = {
        'lua_ls',
        function()
            return {
                default_config = {
                    root_dir = function(fname)
                        local root_pattern = vim.lsp.util.root_pattern('.git', '.root')(fname)

                        if fname == vim.loop.os_homedir() then
                            return nil
                        end
                        return root_pattern or fname
                    end,
                },
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
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
        'pyright',
        'ruff',
    },
    zig = { 'zls' },
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
        dependencies = { 'saghen/blink.cmp' },
        config = function()
            vim.lsp.set_log_level 'off'
            local lsp_config = require 'lspconfig'
            local lsp_utils = require 'plugins.utils.lsp'

            local default_capabilities = require('blink.cmp').get_lsp_capabilities()

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
                    lsp_config[server].setup(lsp_utils.make_default_opts(default_capabilities, config))
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
        'nvimdev/lspsaga.nvim',
        opts = {
            lightbulb = {
                virtual_text = false,
            },
        },
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            'nvim-tree/nvim-web-devicons', -- optional
        },
    },
    {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
            library = {
                'lazy.nvim',
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
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
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        config = function()
            vim.g.rustaceanvim = { server = { on_attach = require('plugins.utils.lsp').custom_attach } }
        end,
        event = { 'BufRead *.rs', 'BufWinEnter *.rs', 'BufNewFile *.rs' },
    },
    {
        -- A neovim plugin that helps managing crates.io dependencies
        'saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        opts = {},
    },
}
