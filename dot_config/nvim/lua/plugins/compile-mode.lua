return {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile' },
    keys = {
        {
            '<F5>',
            CMD 'Recompile',
            mode = { 'n' },
            desc = 'Compile Mode: run compile',
        },
    },
    branch = 'latest',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
    },
    opts = {
        -- you can disable colors by uncommenting this line
        -- no_baleia_support = true,
        default_command = 'make',
    },
}
