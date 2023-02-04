return { --  Peek lines just when you intend
    'nacro90/numb.nvim',
    event = { 'CmdlineChanged', 'CmdlineLeave' },
    config = function()
        require('numb').setup()
    end,
}
