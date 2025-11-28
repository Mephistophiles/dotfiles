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
    'clangd',
    'gopls',
    'jsonls',
    'nixd',
    'lua_ls',
    'pylsp',
    'pyright',
    'ruff',
    'zls',
}

vim.lsp.enable(supported_lsp)

local function debounce(ms, fn)
    local timer = assert(vim.uv.new_timer())
    return function(...)
        local argc, argv = select('#', ...), { ... }
        timer:start(ms, 0, function()
            timer:stop()
            vim.schedule(function()
                fn(unpack(argv, 1, argc))
            end)
        end)
    end
end

local function setup_document_hightlight(bufnr)
    local lsp_document_highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', {
        group = lsp_document_highlight_group,
        buffer = bufnr,
        desc = 'Document highlight',
        callback = debounce(200, function()
            vim.lsp.buf.document_highlight()
        end),
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
        group = lsp_document_highlight_group,
        buffer = bufnr,
        desc = 'Document clear references',
        callback = debounce(200, function()
            vim.lsp.buf.clear_references()
        end),
    })
end

local function setup_code_lens(bufnr)
    local lsp_document_codelens_group = vim.api.nvim_create_augroup('lsp_document_codelens', { clear = false })
    vim.api.nvim_create_autocmd('BufEnter', {
        group = lsp_document_codelens_group,
        buffer = bufnr,
        once = true,
        desc = 'refresh on enter',
        callback = debounce(200, function()
            require('vim.lsp.codelens').refresh()
        end),
    })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'CursorHold' }, {
        group = lsp_document_codelens_group,
        buffer = bufnr,
        desc = 'Refresh references',
        callback = debounce(200, function()
            require('vim.lsp.codelens').refresh()
        end),
    })
end

local lsp_group = vim.api.nvim_create_augroup('LspGroup', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = lsp_group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local client_methods = vim.lsp.protocol.Methods

        if not client then
            vim.notify('Failed to attach to client ' .. vim.inspect(args), vim.log.WARN)
            return
        end

        key_bindings(client)

        if client:supports_method(client_methods.textDocument_formatting) then
            require('formatter').attach_formatter(client, args.buf)
        end

        -- Set autocommands conditional on server_capabilities
        if client:supports_method(client_methods.textDocument_documentHighlight) then
            setup_document_hightlight(args.buf)
        end

        if client:supports_method(client_methods.textDocument_codeLens) then
            setup_code_lens(args.buf)
        end
    end,
})

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menu,noselect,noinsert,fuzzy,popup'

vim.lsp.log.set_level(vim.log.levels.OFF)
vim.diagnostic.config {
    severity_sort = true,
    signs = true,
    update_in_insert = true,
    underline = true,
    virtual_text = { current_line = true },
}
