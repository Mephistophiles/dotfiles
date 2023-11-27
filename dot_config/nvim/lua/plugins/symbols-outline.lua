return { -- A tree like view for symbols in Neovim using the Language Server Protocol. Supports all your favourite languages.
    'simrat39/symbols-outline.nvim',
    cmd = { 'SymbolsOutline' },
    keys = {
        { '<F3>', CMD 'SymbolsOutline', desc = 'SymbolsOutline: Open symbols outline' },
    },
    config = function()
        require('symbols-outline').setup()
    end,
}
