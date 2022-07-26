local M = {}

function M.setup() end

function M.config()
    local Hydra = require 'hydra'
    local splits = require 'smart-splits'

    local border = {
        line = {
            { '🭽', 'FloatBorder' },
            { '▔', 'FloatBorder' },
            { '🭾', 'FloatBorder' },
            { '▕', 'FloatBorder' },
            { '🭿', 'FloatBorder' },
            { '▁', 'FloatBorder' },
            { '🭼', 'FloatBorder' },
            { '▏', 'FloatBorder' },
        },
        chars = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' },
    }

    Hydra {
        name = 'Window management',
        config = {
            hint = {
                border = border,
            },
        },
        mode = 'n',
        body = '<C-w>',
        heads = {
            -- Size
            {
                '+',
                function()
                    splits.resize_up()
                end,
            },
            {
                '-',
                function()
                    splits.resize_down()
                end,
            },
            {
                '>',
                function()
                    splits.resize_right()
                end,
                { desc = 'increase width' },
            },
            {
                '<',
                function()
                    splits.resize_left()
                end,
                { desc = 'decrease width' },
            },
            { '=', '<C-w>=', { desc = 'equalize' } },
            --
            { '<Esc>', nil, { exit = true } },
        },
    }

    Hydra {
        name = 'Side scroll',
        mode = 'n',
        body = 'z',
        heads = {
            { 'h', '5zh' },
            { 'l', '5zl', { desc = '←/→' } },
            { 'H', 'zH' },
            { 'L', 'zL', { desc = 'half screen ←/→' } },
        },
    }
end

return M
