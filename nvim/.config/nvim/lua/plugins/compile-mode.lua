return {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile', 'Recompile' },
    ref = 'latest',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- if you want to enable coloring of ANSI escape codes in
        -- compilation output, add:
        -- { "m00qek/baleia.nvim", tag = "v1.3.0" },
    },
    init = function()
        ---@type CompileModeOpts
        vim.g.compile_mode = {
            -- to add ANSI escape code support, add:
            -- baleia_setup = true,
        }
    end,
}
