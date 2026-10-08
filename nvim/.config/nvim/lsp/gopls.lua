local mod_cache = nil

return {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local function resolve_root()
            if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_buf_get_name(bufnr) ~= fname then
                return
            end

            -- Reuse the workspace when browsing dependencies in the module cache.
            if mod_cache and vim.startswith(fname, mod_cache .. '/') then
                local clients = vim.lsp.get_clients { name = 'gopls' }
                if #clients > 0 and clients[#clients].config.root_dir then
                    on_dir(clients[#clients].config.root_dir)
                    return
                end
            end

            on_dir(vim.fs.root(bufnr, { 'go.work', 'go.mod', '.git' }))
        end

        if mod_cache ~= nil then
            resolve_root()
            return
        end

        if vim.fn.executable 'go' == 0 then
            mod_cache = false
            resolve_root()
            return
        end

        vim.system({ 'go', 'env', 'GOMODCACHE' }, { text = true, timeout = 3000 }, function(result)
            vim.schedule(function()
                local path = result.code == 0 and vim.trim(result.stdout or '') or ''
                mod_cache = path ~= '' and vim.fs.normalize(path) or false
                resolve_root()
            end)
        end)
    end,
}
