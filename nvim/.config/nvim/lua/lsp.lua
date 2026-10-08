local function smart_goto(direction)
    for _, severity in ipairs {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
    } do
        local diagnostic = vim.diagnostic.get(0, { severity = severity })

        if #diagnostic > 0 then
            vim.diagnostic.jump { count = direction, float = true, severity = severity }
            break
        end
    end
end

local function smart_goto_next()
    smart_goto(1)
end

local function smart_goto_prev()
    smart_goto(-1)
end

local function keymap(key, cmd, user_opts)
    local default_opts = { remap = true, buffer = true }
    local opts = vim.tbl_extend('force', default_opts, user_opts or {})

    vim.keymap.set('n', key, cmd, opts)
end

local function key_bindings(client)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    vim.keymap.set('i', '<CR>', function()
        return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
    end, { expr = true, buffer = true, desc = 'Completion: accept completion' })

    keymap('<leader>d', function()
        vim.diagnostic.open_float(nil, { focusable = false, source = 'if_many' })
    end, { desc = 'LSP: show diagnostics floating window' })
    keymap('gD', vim.lsp.buf.declaration, { desc = 'LSP: goto declaration' })
    keymap('gd', vim.lsp.buf.definition, { desc = 'LSP: goto definition' })
    keymap('<leader>D', vim.lsp.buf.type_definition, { desc = 'LSP: goto type definition' })

    -- Call hierarchy
    keymap('<Leader>ci', vim.lsp.buf.incoming_calls, { desc = 'LSP: show all the call sites of the symbol' })
    keymap(
        '<Leader>co',
        vim.lsp.buf.outgoing_calls,
        { desc = 'LSP: show all the items that are called by the symbol under the cursor' }
    )

    keymap('<leader>ql', function()
        vim.diagnostic.setloclist()
    end, { desc = 'LSP: add buffer diagnostics to the location list' })

    vim.keymap.set(
        { 'v', 'n' },
        '<leader>F',
        vim.lsp.buf.format,
        { buffer = true, desc = 'LSP: format document by lsp engine' }
    )

    keymap('<leader>]', function()
        smart_goto_next()
    end, { desc = 'LSP: goto next significant diagnostic' })
    keymap('<leader>[', function()
        smart_goto_prev()
    end, { desc = 'LSP: goto prev significant diagnostic' })

    keymap('<leader>ll', function()
        if not vim.g.virtual_lines_state then
            vim.g.virtual_lines_state = 0
        end

        if vim.g.virtual_lines_state == 0 then
            vim.diagnostic.config { virtual_lines = true }
            vim.g.virtual_lines_state = 1
        elseif vim.g.virtual_lines_state == 1 then
            vim.diagnostic.config { virtual_lines = { current_line = true } }
            vim.g.virtual_lines_state = 2
        elseif vim.g.virtual_lines_state == 2 then
            vim.diagnostic.config { virtual_lines = false }
            vim.g.virtual_lines_state = 0
        end
    end, { desc = 'Toggle virtual lines' })

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
        vim.keymap.set(
            'n',
            '<leader>lr',
            vim.lsp.codelens.run,
            { buffer = true, desc = 'LSP: run code lens in the current line' }
        )
    end
end

local supported_lsp = {
    'buildstream_lsp',
    'clangd',
    'gopls',
    'jsonls',
    'lua_ls',
    'nixd',
    'pyright',
    'ruff',
    'zls',
}

vim.lsp.enable(supported_lsp)

local function setup_completion(client, bufnr)
    local chars = {}
    for i = 32, 126 do
        table.insert(chars, string.char(i))
    end
    client.server_capabilities.completionProvider.triggerCharacters = chars
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

local highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })

local function setup_document_highlight(bufnr)
    vim.api.nvim_clear_autocmds { group = highlight_group, buf = bufnr }
    vim.api.nvim_create_autocmd('CursorHold', {
        group = highlight_group,
        buf = bufnr,
        desc = 'Document highlight',
        callback = function(args)
            if vim.api.nvim_get_current_buf() == args.buf then
                vim.lsp.buf.document_highlight()
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
        group = highlight_group,
        buf = bufnr,
        desc = 'Clear document references',
        callback = function(args)
            vim.lsp.util.buf_clear_references(args.buf)
        end,
    })
end

local lsp_group = vim.api.nvim_create_augroup('LspGroup', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = lsp_group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local client_methods = vim.lsp.protocol.Methods

        if not client then
            vim.notify('Failed to attach to client ' .. vim.inspect(args), vim.log.levels.WARN)
            return
        end

        if client:supports_method(client_methods.textDocument_completion) then
            setup_completion(client, args.buf)
        end

        key_bindings(client)

        if client:supports_method(client_methods.textDocument_formatting) then
            require('formatter').attach_formatter(client, args.buf)
        end

        -- Set autocommands conditional on server_capabilities
        if client:supports_method(client_methods.textDocument_documentHighlight) then
            setup_document_highlight(args.buf)
        end

        if client:supports_method(client_methods.textDocument_codeLens) then
            vim.lsp.codelens.enable(true, { bufnr = args.buf, client_id = client.id })
        end
    end,
})

vim.api.nvim_create_autocmd('LspDetach', {
    group = lsp_group,
    callback = function(args)
        for _, client in ipairs(vim.lsp.get_clients { bufnr = args.buf }) do
            if client.id ~= args.data.client_id
                and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, args.buf)
            then
                return
            end
        end
        vim.api.nvim_clear_autocmds { group = highlight_group, buf = args.buf }
        vim.lsp.util.buf_clear_references(args.buf)
    end,
})

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menu,noselect,noinsert,fuzzy,popup,preselect'

vim.lsp.log.set_level(vim.log.levels.OFF)
vim.diagnostic.config {
    severity_sort = true,
    signs = true,
    update_in_insert = true,
    underline = true,
    virtual_text = { current_line = true },
}
