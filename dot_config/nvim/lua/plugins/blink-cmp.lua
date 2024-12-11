return {
    'saghen/blink.cmp',
    -- event = { 'InsertEnter' },
    lazy = false,
    build = 'cargo build --release',

    -- dependencies = {
    --     'L3MON4D3/LuaSnip',
    -- },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- see the "default configuration" section below for full documentation on how to define
        -- your own keymap.
        keymap = { preset = 'enter' },

        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
        },
        -- snippets = {
        --     expand = function(snippet)
        --         require('luasnip').lsp_expand(snippet)
        --     end,
        --     active = function(filter)
        --         if filter and filter.direction then
        --             return require('luasnip').jumpable(filter.direction)
        --         end
        --         return require('luasnip').in_snippet()
        --     end,
        --     jump = function(direction)
        --         require('luasnip').jump(direction)
        --     end,
        -- },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
            default = {
                'lsp',
                'path',
                -- 'luasnip',
                'buffer',
                'lazydev',
            },
            -- providers = {
            --     -- dont show LuaLS require statements when lazydev has items
            --     lsp = { fallback_for = { 'lazydev' } },
            --     lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
            -- },
        },

        -- experimental auto-brackets support
        completion = { accept = { auto_brackets = { enabled = true } } },

        -- experimental signature help support
        signature = { enabled = true },
    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.default' },

    -- config = function()
    -- for _, ft_path in ipairs(vim.api.nvim_get_runtime_file('lua/snippets/*.lua', true)) do
    --     loadfile(ft_path)()
    -- end
    -- end,
}
