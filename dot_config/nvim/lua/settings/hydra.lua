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
        name = 'Line movement',
        mode = 'v',
        body = '<M-Space>',
        heads = {
            { 'j', [[:m '>+1<CR>gv=gv]], { desc = 'Move line down' } },
            { 'k', [[:m '<-2<CR>gv=gv]], { desc = 'Move line up' } },
        },
    }
end

return M
