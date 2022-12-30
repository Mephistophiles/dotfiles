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

    local pattern = function(from, to)
        return augend.user.new {
            find = require('dial.augend.common').find_pattern(from),
            add = function(text, _, cursor)
                local option = text:match(from)
                local out = string.format(to, option)
                return {
                    text = out,
                    cursor = cursor,
                }
            end,
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
            pattern('^(%S+)=y$', '# %s is not set'),
            pattern('^# (%S+) is not set$', '%s=y'),
        },
    }
end

return M
