return {
    'obsidian-nvim/obsidian.nvim',
    cmd = { 'Obsidian' },
    ft = 'markdown',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    init = function()
        vim.opt.conceallevel = 1
    end,
    opts = {
        workspaces = {
            {
                name = 'Default',
                path = '~/Documents/Knowledge',
                overrides = {
                    notes_subdir = 'Notes',
                },
            },
        },
        completion = {
            nvim_cmp = false,
            blink = true,
        },
    },
}
