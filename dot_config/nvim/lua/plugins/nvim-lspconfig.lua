local utils = require 'plugins.utils.lsp'

local exe_resolve = function(name)
    if vim.fn.exepath(name) then
        return name
    end
end

local servers = {
    lua_ls = {
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
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    },
    -- rust_analyzer = true, -- via rust-tools
    clangd = { capabilities = { offsetEncoding = { 'utf-16' } } },
    gopls = true,
    jsonls = {
        cmd = { exe_resolve 'vscode-json-languageserver' or 'vscode-json-language-server', '--stdio' },
    },
    pylsp = true,
    pyright = true,
}

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
        event = { 'BufRead', 'BufWinEnter', 'BufNewFile' },
        name = 'lspconfig',
        config = function()
            vim.lsp.set_log_level 'off'

            for server, config in pairs(servers) do
                setup_server(server, config)
            end
        end,
    },
    {
        'glepnir/lspsaga.nvim',
        event = 'LspAttach',
        config = function()
            require('lspsaga').setup {}
        end,
        dependencies = {
            { 'nvim-tree/nvim-web-devicons' },
            --Please make sure you install markdown and markdown_inline parser
            { 'nvim-treesitter/nvim-treesitter' },
        },
    },
}
