return {
    'smoka7/multicursors.nvim',
    dependencies = {
        'nvimtools/hydra.nvim',
    },
    opts = {},
    cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
    keys = {
        {
            mode = { 'v', 'n' },
            '<Leader>n',
            '<cmd>MCstart<cr>',
            desc = 'Multicursors: Create a selection for selected text or word under the cursor',
        },
    },
}
