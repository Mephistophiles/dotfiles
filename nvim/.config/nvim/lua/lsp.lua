vim.g.builtin_completion = true

local function smart_goto(fn)
    for _, severity in ipairs {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
    } do
        local diagnostic = vim.diagnostic.get(0, { severity = severity })

        if #diagnostic > 0 then
            fn(severity)
            break
        end
    end
end

local function smart_goto_next()
    smart_goto(function(severity)
        vim.diagnostic.goto_next {
            severity = severity,
        }
    end)
end

local function smart_goto_prev()
    smart_goto(function(severity)
        vim.diagnostic.goto_prev {
            severity = severity,
        }
    end)
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
            vim.g.virtual_lines_state = 1
        end

        if vim.g.virtual_lines_state == 0 then
            vim.diagnostic.config { virtual_lines = { current_line = true } }
            vim.g.virtual_lines_state = 1
        elseif vim.g.virtual_lines_state == 1 then
            vim.diagnostic.config { virtual_lines = true }
            vim.g.virtual_lines_state = 2
        elseif vim.g.virtual_lines_state == 2 then
            vim.diagnostic.config { virtual_lines = false }
            vim.g.virtual_lines_state = 0
        end
    end, { desc = 'Toggle virtual lines' })

    if client.supports_method 'textDocument/codeLens' then
        vim.keymap.set(
            'n',
            '<leader>lr',
            vim.lsp.codelens.run,
            { buffer = true, desc = 'LSP: run code lens in the current line' }
        )
    end
end

local supported_lsp = {
    {
        language_list = { 'c', 'cpp' },
        lsp_list = { 'clangd' },
    },
    {
        language_list = { 'go' },
        lsp_list = { 'gopls' },
    },
    {
        language_list = { 'json' },
        lsp_list = { 'jsonls' },
    },
    {
        language_list = { 'nix' },
        lsp_list = { 'nixd' },
    },
    {
        language_list = { 'lua' },
        lsp_list = { 'lua_ls' },
    },
    {
        language_list = { 'python' },
        lsp_list = { 'pylsp', 'pyright', 'ruff' },
    },
    {
        language_list = { 'zig' },
        lsp_list = { 'zls' },
    },
}

local lsp_group = vim.api.nvim_create_augroup('LspGroup', { clear = true })

for _, supported in ipairs(supported_lsp) do
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = supported.language_list,
        group = lsp_group,
        callback = function()
            vim.lsp.enable(supported.lsp_list)
        end,
    })
end

local function setup_completion(client, bufnr)
    vim.tbl_extend('force', client.server_capabilities.completionProvider.triggerCharacters, {
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        '.',
        ':',
        ' ',
    })
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

    ---[[Code required to add documentation popup for an item
    local _, cancel_prev = nil, function() end
    vim.api.nvim_create_autocmd('CompleteChanged', {
        buffer = bufnr,
        callback = function()
            cancel_prev()
            local info = vim.fn.complete_info { 'selected' }
            local completionItem = vim.tbl_get(vim.v.completed_item, 'user_data', 'nvim', 'lsp', 'completion_item')
            if nil == completionItem then
                return
            end
            _, cancel_prev = vim.lsp.buf_request(
                bufnr,
                vim.lsp.protocol.Methods.completionItem_resolve,
                completionItem,
                function(err, item, ctx)
                    if not item then
                        return
                    end
                    local docs = (item.documentation or {}).value
                    local win = vim.api.nvim__complete_set(info['selected'], { info = docs })
                    if win.winid and vim.api.nvim_win_is_valid(win.winid) then
                        vim.treesitter.start(win.bufnr, 'markdown')
                        vim.wo[win.winid].conceallevel = 3
                    end
                end
            )
        end,
    })
    ---]]
end

local function setup_document_hightlight(bufnr)
    local lsp_document_highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', {
        group = lsp_document_highlight_group,
        buffer = bufnr,
        desc = 'Document highlight',
        callback = function()
            vim.lsp.buf.document_highlight()
        end,
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
        group = lsp_document_highlight_group,
        buffer = bufnr,
        desc = 'Document clear references',
        callback = function()
            vim.lsp.buf.clear_references()
        end,
    })
end

local function setup_code_lens(bufnr)
    local lsp_document_codelens_group = vim.api.nvim_create_augroup('lsp_document_codelens', { clear = false })
    vim.api.nvim_create_autocmd('BufEnter', {
        group = lsp_document_codelens_group,
        buffer = bufnr,
        once = true,
        desc = 'refresh on enter',
        callback = function()
            require('vim.lsp.codelens').refresh()
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'CursorHold' }, {
        group = lsp_document_codelens_group,
        buffer = bufnr,
        desc = 'Refresh references',
        callback = function()
            require('vim.lsp.codelens').refresh()
        end,
    })
end

local client_methods = vim.lsp.protocol.Methonds

vim.api.nvim_create_autocmd('LspAttach', {
    group = lsp_group,
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if vim.g.builtin_completion and client:supports_method(client_methods.textDocument_completion) then
            setup_completion(client, args.buf)
        end

        key_bindings(client)

        if client:supports_method(client_methods.textDocument_formatting) then
            require('plugins.utils.formatter').attach_formatter(client, args.buf)
        end

        -- Set autocommands conditional on server_capabilities
        if client:supports_metho(client_methods.textDocument_documentHighlight) then
            setup_document_hightlight(args.buf)
        end

        if client:supports_method(client_methods.textDocument_codeLens) then
            setup_code_lens(args.buf)
        end
    end,
})

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menu,noselect,noinsert,fuzzy,popup'

vim.lsp.set_log_level 'off'
vim.diagnostic.config {
    severity_sort = true,
    signs = true,
    update_in_insert = true,
    underline = true,
    virtual_lines = { current_line = true },
}
