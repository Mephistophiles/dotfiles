return { -- A file explorer tree for neovim written in lua
    'nvim-tree/nvim-tree.lua',
    dependencies = {
        'kyazdani42/nvim-web-devicons',
    },
    keys = {
        {
            [[<leader>g]],
            function()
                local bufnr = vim.api.nvim_get_current_buf()
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                local filepath = vim.fn.fnamemodify(bufname, ':p')

                require('nvim-tree.api').tree.open()
                require('nvim-tree.api').tree.find_file(filepath)
            end,
            desc = 'Nvimtree: select current file',
        },
        {
            [[<C-g>]],
            function()
                require('nvim-tree.api').tree.toggle(false, true)
            end,
            desc = 'Nvimtree: toggle',
        },
    },
    config = function()
        require('nvim-tree').setup { sync_root_with_cwd = true, respect_buf_cwd = true }
    end,
    version = 'nightly', -- optional, updated every week. (see issue #1193)
}
