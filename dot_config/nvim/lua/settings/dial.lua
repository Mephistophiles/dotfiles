local M = {}

function M.setup() end

function M.config()
    local augend = require 'dial.augend'

    local cycle = function(elements)
        return augend.constant.new {
            elements = elements,
            word = true,
            cyclic = true,
        }
    end

    require('dial.config').augends:register_group {
        -- default augends used when no group name is specified
        default = {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.constant.alias.bool,
            augend.semver.alias.semver,
            augend.date.alias['%Y/%m/%d'],
            augend.date.alias['%Y-%m-%d'],
            augend.date.alias['%m/%d'],
            augend.date.alias['%H:%M'],
            cycle { 'd_str_t', 'd_str_auto_t' },
            cycle { 'json_t', 'json_auto_t' },
            cycle { 'd_jrpcmsg_t', 'd_jrpcmsg_auto_t' },
            cycle { 'd_dynarray_t', 'd_dynarray_auto_t' },
            cycle { 'd_vect_t', 'd_vect_auto_t' },
            cycle { 'json_object_set_nocheck', 'json_object_set_new_nocheck' },
            cycle { 'json_object_set', 'json_object_set_new' },
            cycle { 'json_array_append', 'json_array_append_new' },
            augend.user.new {
                find = require('dial.augend.common').find_pattern '^(%S+)=y$',
                add = function(text, _, cursor)
                    local option = text:match '^(%S+)=y$'
                    local out = string.format('# %s is not set', option)
                    return {
                        text = out,
                        cursor = cursor,
                    }
                end,
            },
            augend.user.new {
                find = require('dial.augend.common').find_pattern '^# (%S+) is not set$',
                add = function(text, _, cursor)
                    local option = text:match '^# (%S+) is not set$'
                    local out = string.format('%s=y', option)
                    return {
                        text = out,
                        cursor = cursor,
                    }
                end,
            },
        },
    }

    vim.api.nvim_set_keymap('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true, desc = 'Increment' })
    vim.api.nvim_set_keymap('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true, desc = 'Decrement' })
    vim.api.nvim_set_keymap('v', '<C-a>', require('dial.map').inc_visual(), { noremap = true, desc = 'Increment' })
    vim.api.nvim_set_keymap('v', '<C-x>', require('dial.map').dec_visual(), { noremap = true, desc = 'Decrement' })
    vim.api.nvim_set_keymap('v', 'g<C-a>', require('dial.map').inc_gvisual(), { noremap = true, desc = 'Increment' })
    vim.api.nvim_set_keymap('v', 'g<C-x>', require('dial.map').dec_gvisual(), { noremap = true, desc = 'Decrement' })
end

return M
