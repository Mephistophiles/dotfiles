return { -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    'sindrets/diffview.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
}
