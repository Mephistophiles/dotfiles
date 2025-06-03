local function parse_url(url)
    return url:match '^(.*://)(.*)$'
end

local function maybe_hijack_directory_buffer(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == '' then
        return false
    end
    if parse_url(bufname) or vim.fn.isdirectory(bufname) == 0 then
        return false
    end

    return true
end

local lazy_group = vim.api.nvim_create_augroup('LazyOil', { clear = true })

vim.api.nvim_create_autocmd('User', {
    desc = 'Try to setup oil if we open a directory',
    group = lazy_group,
    pattern = 'LazyDone',
    callback = function()
        if maybe_hijack_directory_buffer(vim.api.nvim_get_current_buf()) then
            require('lazy').load { plugins = { 'oil.nvim' } }
        end
    end,
})
vim.api.nvim_create_autocmd('BufWinEnter', {
    group = lazy_group,
    pattern = '*',
    callback = function()
        if maybe_hijack_directory_buffer(vim.api.nvim_get_current_buf()) then
            require('lazy').load { plugins = { 'oil.nvim' } }
        end
    end,
})

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
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        -- If netrw was already loaded, clear this augroup
        if vim.fn.exists '#FileExplorer' then
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
