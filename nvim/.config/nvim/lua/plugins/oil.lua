return {
    'stevearc/oil.nvim',
    cmd = { 'Oil' },
    keys = {
        {
            '-',
            function()
                require('oil').open_float()
            end,
            mode = { 'n' },
            desc = 'Oil: Open parent directory',
        },
    },
    init = function()
        -- Use Neovim's dir explorer for directories, Oil only on request.
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
        default_file_explorer = false,
        view_options = {
            show_hidden = true,
        },
        keymaps = {
            ['<C-p>'] = { 'actions.preview', mode = 'n' },
            ['<C-s>'] = nil,
            ['<C-h>'] = nil,
            ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
            ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
        },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}
