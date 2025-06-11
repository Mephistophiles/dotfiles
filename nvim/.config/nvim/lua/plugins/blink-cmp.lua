return {
    'saghen/blink.cmp',
    event = { 'LspAttach' },
    build = 'cargo build --release',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- see the "default configuration" section below for full documentation on how to define
        -- your own keymap.
        keymap = {
            preset = 'default',
            ['<CR>'] = { 'accept', 'fallback' },
            ['<Tab>'] = {
                function(cmp)
                    if cmp.snippet_active() then
                        return cmp.accept()
                    else
                        return cmp.select_and_accept()
                    end
                end,
                'snippet_forward',
                'fallback',
            },
        },

        cmdline = { enabled = true },
        fuzzy = {
            implementation = 'prefer_rust',
            sorts = {
                'exact',
                -- defaults
                'score',
                'sort_text',
            },
        },

        appearance = {
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
        },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
            default = {
                'lsp',
                'path',
                'snippets',
                'buffer',
            },
            providers = {
                lsp = { fallbacks = {} },
            },
        },

        completion = {
            -- Don't select by default, auto insert on selection
            list = { selection = { preselect = false, auto_insert = true } },
            trigger = { show_on_keyword = true },
        },

        -- experimental signature help support
        signature = { enabled = true },
    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.default' },
}
