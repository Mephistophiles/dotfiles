return { -- tmux integration for nvim features pane movement and resizing from within nvim.
    'aserowy/tmux.nvim',
    keys = {
        { '<c-h>', CMD 'lua require("tmux").move_left()', desc = 'Left movement' },
        { '<c-j>', CMD 'lua require("tmux").move_bottom()', desc = 'Bottom movement' },
        { '<c-k>', CMD 'lua require("tmux").move_top()', desc = 'Top movement' },
        { '<c-l>', CMD 'lua require("tmux").move_right()', desc = 'Right movement' },
        { '<a-h>', CMD 'lua require("tmux").resize_left()', desc = 'Resize to left' },
        { '<a-j>', CMD 'lua require("tmux").resize_bottom()', desc = 'Resize to bottom' },
        { '<a-k>', CMD 'lua require("tmux").resize_top()', desc = 'Resize to top' },
        { '<a-l>', CMD 'lua require("tmux").resize_right()', desc = 'Resize to right' },
    },
    config = function()
        require('tmux').setup {
            -- overwrite default configuration
            -- here, e.g. to enable default bindings
            copy_sync = {
                -- enables copy sync and overwrites all register actions to
                -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
                enable = false,
            },
        }
    end,
}
