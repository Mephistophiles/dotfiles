local root_files = {
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
}

local settings = {
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
}

return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = root_files,
    settings = settings,
}
