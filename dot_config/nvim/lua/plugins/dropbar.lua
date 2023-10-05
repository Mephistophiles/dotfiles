return {
    {
        'Bekaboo/dropbar.nvim',
        enabled = function()
            local version = vim.version()
            version = { version.major, version.minor, version.patch }
            return vim.version.cmp(version, { 0, 10, 0 }) > -1
        end,
        -- optional, but required for fuzzy finder support
        -- dependencies = {
        --   'nvim-telescope/telescope-fzf-native'
        -- }
    },
}
