return {
    -- A neovim plugin that helps managing crates.io dependencies
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    dependencies = { { 'nvim-lua/plenary.nvim' } },
    opts = {},
}
