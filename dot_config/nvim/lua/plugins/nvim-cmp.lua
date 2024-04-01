vim.api.nvim_create_autocmd('LspAttach', {
    callback = function()
        require('lazy').load { plugins = { 'nvim-cmp' } }
    end,
})
return {
    -- A completion plugin for neovim coded in Lua.
    'hrsh7th/nvim-cmp',
    lazy = true,
    event = { 'InsertEnter' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp', -- language server protocol
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-buffer', -- completion from current buffer
        'hrsh7th/cmp-path', -- completion for filesystem
        'L3MON4D3/LuaSnip',
    },
    config = function()
        local cmp = require 'cmp'
        local types = require 'cmp.types'
        local source_mapping = {
            buffer = '[Buffer]',
            nvim_lsp = '[LSP]',
            path = '[Path]',
            crates = '[Crates.io]',
        }

        cmp.setup {
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
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
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<c-y>'] = cmp.mapping(
                    cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    { 'i', 'c' }
                ),
                ['<right>'] = cmp.mapping(
                    cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    },
                    { 'i' }
                ),
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

        vim.keymap.set({ 'i', 's' }, '<Tab>', function()
            if require('luasnip').jumpable(1) then
                return CMD 'lua require("luasnip").jump(1)'
            else
                return '<Tab>'
            end
        end, { expr = true })
        vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
            if require('luasnip').jumpable(-1) then
                return CMD 'lua require("luasnip").jump(-1)'
            else
                return '<Tab>'
            end
        end, { expr = true })
    end,
}
