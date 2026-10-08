return {
    'stevearc/oil.nvim',
    lazy = false,
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
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        -- If netrw was already loaded, clear this augroup
        if vim.fn.exists '#FileExplorer' == 1 then
            vim.api.nvim_create_augroup('FileExplorer', { clear = true })
        end
    end,
    opts = {
        default_file_explorer = true,
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
