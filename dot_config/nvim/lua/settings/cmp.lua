local M = {}

function M.setup()
    local cmp = require 'cmp'
    local lspkind = require 'lspkind'
    local luasnip = require 'luasnip'
    local source_mapping = {
        buffer = '[Buffer]',
        nvim_lsp = '[LSP]',
        luasnip = '[LuaSnip]',
        path = '[Path]',
        cmp_tabnine = '[TabNine]',
        crates = '[Crates.io]',
    }

    cmp.setup {
        formatting = {
            format = function(entry, vim_item)
                vim_item.kind = lspkind.presets.default[vim_item.kind]
                local menu = source_mapping[entry.source.name]
                if entry.source.name == 'cmp_tabnine' then
                    if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
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
            ['<c-space>'] = cmp.mapping {
                i = cmp.mapping.complete {},
                c = function(
                    _ --[[fallback]]
                )
                    if cmp.visible() then
                        if not cmp.confirm { select = true } then
                            return
                        end
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        cmp.complete()
                    end
                end,
            },
            -- Testing
            ['<c-q>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
        },
        sources = {
            { name = 'luasnip' }, -- snippet engine
            { name = 'nvim_lsp' }, -- language server protocol
            -- { name = 'cmp_tabnine' }, -- tabnine
            { name = 'copilot' }, -- copilot
            { name = 'neorg' },
            { name = 'path' }, -- completion from FS
            { name = 'buffer', keyword_length = 5 }, -- completion from buffer
            { name = 'crates' }, -- crates
        },
        sorting = {
            priority_weight = 10,
            comparators = {
                cmp.config.compare.offset, -- offset
                cmp.config.compare.exact, -- exact
                cmp.config.compare.recently_used, -- resently used
                cmp.config.compare.score, -- score (priority based)
                cmp.config.compare.kind, -- kind based
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
        view = { entries = 'native' },
        experimental = { ghost_text = true },
    }
end

return M
