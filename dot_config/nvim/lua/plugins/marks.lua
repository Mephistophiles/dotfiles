return { -- A better user experience for viewing and interacting with Vim marks.
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    config = function()
        require('marks').setup { default_mappings = true }
    end,
}
