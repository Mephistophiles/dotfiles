return {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
    keys = {
        {
            '<space>j',
            CMD 'TSJToggle',
            desc = 'TreeSJ: toggle node under cursor (split if one-line and join if multiline)',
        },
    },
    opts = {},
}
