return { -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    'sindrets/diffview.nvim',
    enabled = false,
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = { 'DiffviewOpen' },
}
