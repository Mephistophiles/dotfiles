local utils = require 'plugins.utils.lsp'

local exe_resolve = function(name, default)
    if vim.fn.exepath(name) then
        return name
    end

    return default
end

local setup_server = function(server, config)
    if not config then
        return
    end

    if type(config) == 'function' then
        config = config()

        if not config then
            return
        end
    end

    if type(config) ~= 'table' then
        config = {}
    end

    config = vim.tbl_deep_extend('force', utils.make_default_opts(), config)

    require('lspconfig')[server].setup(config)
end

return {
    { -- Quickstart configs for Nvim LSP
        'neovim/nvim-lspconfig',
        name = 'lspconfig',
        config = function()
            local servers = {
                lua_ls = function()
                    local runtime_path = vim.split(package.path, ';')
                    table.insert(runtime_path, 'lua/?.lua')
                    table.insert(runtime_path, 'lua/?/init.lua')

                    return {
                        settings = {
                            Lua = {
                                runtime = {
                                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                                    version = 'LuaJIT',

                                    -- Setup your lua path
                                    path = runtime_path,
                                },
                                diagnostics = {
                                    -- Get the language server to recognize the `vim` global
                                    globals = { 'vim' },
                                },
                                workspace = {
                                    -- Make the server aware of Neovim runtime files
                                    library = vim.api.nvim_get_runtime_file('', true),
                                },
                                -- Do not send telemetry data containing a randomized but unique identifier
                                telemetry = { enable = false },
                            },
                        },
                    }
                end,
                -- rust_analyzer = true, -- via rust-tools
                clangd = { capabilities = { offsetEncoding = { 'utf-16' } } },
                gopls = true,
                hls = true,
                jsonls = {
                    cmd = { exe_resolve('vscode-json-languageserver', 'vscode-json-language-server'), '--stdio' },
                },
                pylsp = true,
                pyright = true,
                rnix = true,
            }

            vim.lsp.set_log_level 'off'

            for server, config in pairs(servers) do
                setup_server(server, config)
            end
        end,
        dependencies = {
            -- LSP modules
        },
    },
    {
        'ray-x/lsp_signature.nvim',
        event = 'VeryLazy',
        config = {
            toggle_key = '<C-S>',
            floating_window = false,
        },
        dependencies = { 'neovim/nvim-lspconfig', name = 'lspconfig' },
    },
    { 'loctvl842/breadcrumb.nvim', event = 'VeryLazy', config = {}, dependencies = { 'nvim-tree/nvim-web-devicons' } },
    {
        'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        event = 'VeryLazy',
        config = function()
            local enabled = false
            local bootstrap = true
            local original_cpo = vim.opt.cpoptions

            local function lsp_lines_toggle()
                enabled = not enabled

                if enabled then
                    vim.diagnostic.config {
                        virtual_text = false, -- Since we're using lsp_lines
                    }
                    vim.opt.cpoptions:remove 'n'
                else
                    vim.diagnostic.config {
                        virtual_text = true, -- Since we're using lsp_lines
                    }
                    vim.opt.cpoptions = original_cpo
                end

                if bootstrap then
                    require('lsp_lines').setup()
                    require('lsp_lines').toggle() -- hack for right init
                    bootstrap = false
                end
                require('lsp_lines').toggle()
            end

            vim.keymap.set('', '<leader>ll', function()
                lsp_lines_toggle()
            end, { desc = 'LspLines: Toggle lsp lines' })
            vim.api.nvim_create_user_command('LspLinesToggle', function()
                lsp_lines_toggle()
            end, { nargs = 0 })
        end,
    },
}
