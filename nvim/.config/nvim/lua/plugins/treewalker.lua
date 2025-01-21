return {
    'aaronik/treewalker.nvim',
    keys = {
        { '<a-h>', CMD 'Treewalker Left', desc = 'Treewalker: left movement' },
        { '<a-j>', CMD 'Treewalker Down', desc = 'Treewalker: down movement' },
        { '<a-k>', CMD 'Treewalker Up', desc = 'Treewalker: up movement' },
        { '<a-l>', CMD 'Treewalker Right', desc = 'Treewalker: right movement' },
        { '<c-a-h>', CMD 'Treewalker SwapLeft', desc = 'Treewalker: swap left' },
        { '<c-a-j>', CMD 'Treewalker SwapDown', desc = 'Treewalker: swap down' },
        { '<c-a-k>', CMD 'Treewalker SwapUp', desc = 'Treewalker: swap up' },
        { '<c-a-l>', CMD 'Treewalker SwapRight', desc = 'Treewalker: swap right' },
    },
    opts = {
        highlight = true, -- Whether to briefly highlight the node after jumping to it
    },
}
