vim.api.nvim_create_autocmd('LspAttach', {
    callback = function()
        require('lazy').load { plugins = { 'nvim-cmp' } }
    end,
})
return {
    -- A completion plugin for neovim coded in Lua.
    'iguanacucumber/magazine.nvim', --'hrsh7th/nvim-cmp',
    name = 'nvim-cmp',
    lazy = true,
    event = { 'InsertEnter' },
    dependencies = {
        { 'iguanacucumber/mag-nvim-lsp', name = 'cmp-nvim-lsp' }, -- language server protocol
        'hrsh7th/cmp-nvim-lsp-signature-help',
        { 'iguanacucumber/mag-buffer', name = 'cmp-buffer' }, -- completion from current buffer
        'hrsh7th/cmp-path', -- completion for filesystem
        'L3MON4D3/LuaSnip',
    },
    config = function()
        local ls = require 'luasnip'
        local cmp = require 'cmp'
        local types = require 'cmp.types'
        local source_mapping = {
            buffer = '[Buffer]',
            nvim_lsp = '[LSP]',
            path = '[Path]',
            crates = '[Crates.io]',
        }

        for _, ft_path in ipairs(vim.api.nvim_get_runtime_file('lua/snippets/*.lua', true)) do
            loadfile(ft_path)()
        end

        cmp.setup {
            snippet = {
                expand = function(args)
                    ls.lsp_expand(args.body)
                end,
            },
            formatting = {
                format = function(entry, vim_item)
                    local menu = source_mapping[entry.source.name]
                    vim_item.menu = menu
                    return vim_item
                end,
            },
            mapping = cmp.mapping.preset.insert {
                ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                ['<c-y>'] = cmp.mapping(
                    cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    { 'i' }
                ),
                ['<right>'] = cmp.mapping(
                    cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    { 'i' }
                ),

                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
            },
            sources = {
                { name = 'nvim_lsp' }, -- language server protocol
                { name = 'nvim_lsp_signature_help' },
                { name = 'path' }, -- completion from FS
                {
                    name = 'buffer',
                    keyword_length = 5,
                }, -- completion from buffer
                { name = 'nvim_lua' },
                { name = 'neorg' },
                { name = 'crates' }, -- crates
            },
            sorting = {
                priority_weight = 10,
                comparators = {
                    cmp.config.compare.offset, -- offset
                    cmp.config.compare.exact, -- exact
                    cmp.config.compare.recently_used, -- resently used
                    cmp.config.compare.score, -- score (priority based)
                    -- cmp.config.compare.kind, -- kind based
                    function(entry1, entry2)
                        local kind1 = entry1:get_kind()
                        local kind2 = entry2:get_kind()
                        kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
                        kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
                        if kind1 ~= kind2 then
                            local diff = kind1 - kind2
                            if diff < 0 then
                                return true
                            elseif diff > 0 then
                                return false
                            end
                        end
                        return nil
                    end,
                    cmp.config.compare.sort_text, -- text based (alpha sort)
                    cmp.config.compare.length, -- length sort
                    cmp.config.compare.order, -- source order sort
                    cmp.config.compare.locality,
                },
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            preselect = cmp.PreselectMode.None,
        }

        vim.keymap.set({ 'i', 's' }, '<C-k>', function()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, { silent = true })
        vim.keymap.set({ 'i', 's' }, '<C-j>', function()
            if ls.jumpable(-1) then
                ls.jump(-1)
            end
        end, { silent = true })
    end,
}
