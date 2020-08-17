local M = {}

function M.setup()
    local cmp = require 'cmp'
    local types = require('cmp.types')

    local cmp_kind = function(entry1, entry2)
        local kind1 = entry1:get_kind()
        kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
        local kind2 = entry2:get_kind()
        kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
        if kind1 ~= kind2 then
            local diff = kind1 - kind2
            if diff < 0 then
                return true
            elseif diff > 0 then
                return false
            end
        end
    end

    local lspkind = require('lspkind')
    local source_mapping = {
        buffer = '[Buffer]',
        nvim_lsp = '[LSP]',
        luasnip = '[LuaSnip]',
        path = '[Path]',
        cmp_tabnine = '[TabNine]',
        crates = '[Crates.io]',
    }

    cmp.setup({
        formatting = {
            format = function(entry, vim_item)
                vim_item.kind = lspkind.presets.default[vim_item.kind]
                local menu = source_mapping[entry.source.name]
                if entry.source.name == 'cmp_tabnine' then
                    if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~=
                        nil then
                        menu = entry.completion_item.data.detail .. ' ' .. menu
                    end
                    vim_item.kind = ''
                end
                vim_item.menu = menu
                return vim_item
            end,
        },
        mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-e>'] = cmp.mapping.close(),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<c-y>'] = cmp.mapping(cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }, {'i', 'c'}),
            ['<right>'] = cmp.mapping(cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }, {'i'}),
            ['<c-space>'] = cmp.mapping {
                i = cmp.mapping.complete(),
                c = function(_ --[[fallback]] )
                    if cmp.visible() then
                        if not cmp.confirm {select = true} then return end
                    else
                        cmp.complete()
                    end
                end,
            },
            -- Testing
            ['<c-q>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Replace, select = true},
        },
        sources = {
            {name = 'cmp_tabnine'}, -- tabnine
            {name = 'nvim_lsp'}, -- language server protocol
            {name = 'luasnip'}, -- snippet engine
            {name = 'path'}, -- completion from FS
            {name = 'buffer', keyword_length = 5}, -- completion from buffer
            {name = 'crates'}, -- crates
        },
        sorting = {
            priority_weight = 10,
            comparators = {
                cmp.config.compare.offset, -- offset
                cmp.config.compare.exact, -- exact
                cmp.config.compare.score, -- score (priority based)
                cmp_kind, -- kind based
                cmp.config.compare.sort_text, -- text based (alpha sort)
                cmp.config.compare.length, -- length sort
                cmp.config.compare.order, -- source order sort
            },
        },
        snippet = {
            expand = function(args)
                -- For `luasnip` user.
                require('luasnip').lsp_expand(args.body)
            end,
        },
        experimental = {native_menu = true, ghost_text = true},
    })
end

return M
