return { -- a lua powered greeter like vim-startify / dashboard-nvim
    'goolord/alpha-nvim',
    enabled = false,
    cond = function()
        -- don't start when opening a file
        if vim.fn.argc() > 0 then
            return false
        end

        -- skip stdin
        if vim.fn.line2byte '$' ~= -1 then
            return false
        end

        -- Handle nvim -M
        if not vim.o.modifiable then
            return false
        end

        for _, arg in pairs(vim.v.argv) do
            -- whitelisted arguments
            -- always open
            if arg == '--startuptime' then
                return true
            end

            -- blacklisted arguments
            -- always skip
            if
                arg == '-b'
                -- commands, typically used for scripting
                or arg == '-c'
                or vim.startswith(arg, '+')
                or arg == '-S'
            then
                return false
            end
        end

        return true
    end,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('alpha').setup(require('alpha.themes.startify').config)
    end,
}
