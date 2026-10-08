return {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    on_attach = function(client)
        -- Pyright provides hover, types and navigation.
        client.server_capabilities.hoverProvider = false
    end,
}
