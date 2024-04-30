return {
    'gabrielpoca/replacer.nvim',
    opts = { rename_files = false },
    keys = {
        {
            '<leader>qr',
            function()
                require('replacer').run()
            end,
            desc = 'run replacer.nvim',
        },
    },
}
