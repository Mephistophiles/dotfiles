return {
    'andythigpen/nvim-coverage',
    cmd = {
        'Coverage',
        'CoverageLoad',
        'CoverageLoadLcov',
    },
    main = 'coverage',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
}
