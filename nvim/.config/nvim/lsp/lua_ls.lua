local config_root = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)))
config_root = vim.uv.fs_realpath(config_root) or config_root

return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = {
        '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml',
        'stylua.toml', 'selene.toml', 'selene.yml', '.git',
    },
    settings = {
        Lua = {
            completion = { callSnippet = 'Replace' },
            telemetry = { enable = false },
        },
    },
    on_init = function(client)
        local root = client.config.root_dir
        root = root and (vim.uv.fs_realpath(root) or root)
        if root ~= config_root then
            return
        end

        -- Neovim libraries belong only to this config's Lua workspace.
        local library = vim.api.nvim_get_runtime_file('lua', true)
        vim.list_extend(library, vim.fn.glob(
            vim.fn.stdpath 'data' .. '/site/pack/core/opt/*/lua', false, true
        ))
        client.config.settings.Lua.workspace = {
            library = vim.list.unique(library),
            checkThirdParty = false,
        }
    end,
}
