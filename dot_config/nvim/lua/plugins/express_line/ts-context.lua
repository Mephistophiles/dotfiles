--[[
KNOWN BUGS:
[ ] field names in tables
]]

local utils = require 'plugins.express_line.utils'
local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local QUERY_FIELD_NAME = 1
local QUERY_NODE_TYPE = 2
local function f(name)
    return {
        name = name,
        kind = QUERY_FIELD_NAME,
    }
end

local function t(name)
    return {
        name = name,
        kind = QUERY_NODE_TYPE,
    }
end

local config = {
    node_text_query = {
        ['field'] = {
            lua = { { f 'name' } },
        },
        ['function_call'] = {
            c = { { f 'declarator', f 'declarator' } },
            lua = { { f 'name' } },
        },
        ['function_declaration'] = {
            c = { { f 'declarator', f 'declarator' } },
            lua = { { f 'name' } },
        },
        ['function_definition'] = {
            c = { { f 'declarator', f 'declarator' } },
        },
        ['assignment_statement'] = {
            lua = { { t 'variable_list', f 'name' } },
        },
        ['struct'] = {
            lua = { { t 'field', f 'name' } },
        },
    },
    patterns = {
        default = {
            'assignment_statement',
            'case',
            'do_statement',
            'enum',
            'field',
            'for_statement',
            'function_declaration',
            'function_definition',
            'function_call',
            'if_statement',
            'interface',
            'struct',
            'switch_statement',
            'while_statement',
        },
        lua = {
            'repeat_statement',
        },
    },

    exclude_patterns = {
        default = {},
    },

    icons = {
        ['case'] = ' case',
        ['do_statement'] = ' do',
        ['enum'] = '練',
        ['field'] = '',
        ['for_statement'] = ' for',
        ['function_call'] = '',
        ['function_declaration'] = '',
        ['function_definition'] = '',
        ['if_statement'] = ' if',
        ['interface'] = '練',
        ['struct'] = '',
        ['switch_statement'] = ' switch',
        ['assignment_statement'] = '',
        ['while_statement'] = ' while',
    },
}

local M = {}

local function get_root_node()
    local tree = parsers.get_parser():parse()[1]
    return tree:root()
end

local function is_excluded(node, filetype)
    local node_type = node:type()
    for _, rgx in ipairs(config.exclude_patterns.default) do
        if node_type:find(rgx) then
            return true
        end
    end
    local filetype_patterns = config.exclude_patterns[filetype]
    for _, rgx in ipairs(filetype_patterns or {}) do
        if node_type:find(rgx) then
            return true
        end
    end
    return false
end

local function is_valid(node, filetype)
    if is_excluded(node, filetype) then
        return false
    end

    local node_type = node:type()
    for _, rgx in ipairs(config.patterns.default) do
        if node_type:find(rgx) then
            return true
        end
    end
    local filetype_patterns = config.patterns[filetype]
    for _, rgx in ipairs(filetype_patterns or {}) do
        if node_type:find(rgx) then
            return true
        end
    end
    return false
end

local function find_node(node, query)
    if query.kind == QUERY_FIELD_NAME then
        local fields = node:field(query.name)
        if fields and fields[1] then
            return fields[1]
        end
    elseif query.kind == QUERY_NODE_TYPE then
        local children = ts_utils.get_named_children(node)
        local child = nil
        for _, c in ipairs(children) do
            if c:type() == query.name then
                child = c
                break
            end
        end

        if child then
            return child
        end
    end
end

local function find_node_by_queries(node, queries)
    for _, query in ipairs(queries) do
        node = find_node(node, query)

        if not node then
            break
        end
    end

    return node
end

local function get_text_for_node(node)
    local type = node:type()
    local symbol = config.icons[type]
    local filetype = vim.bo.filetype
    local queries = (config.node_text_query[type] or {})[filetype]

    if queries then
        local child
        for _, q in ipairs(queries) do
            local n = find_node_by_queries(node, q)
            if n then
                child = n
                break
            end
        end

        if child then
            local child_text = vim.treesitter.query.get_node_text(child, 0)
            if symbol then
                return symbol .. ' ' .. child_text
            else
                return child_text
            end
        end
    end

    return symbol
end

local function get_context()
    if not parsers.has_parser() then
        return {}
    end

    local root_node = get_root_node()
    local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line_offset = 0

    -- save nodes in a table to iterate from top to bottom
    local parents = {}

    local offset_lnum = lnum + line_offset - 1
    local node = root_node:named_descendant_for_range(offset_lnum, col, offset_lnum, col)

    if not node then
        return {}
    end

    parents = {}

    while node ~= nil do
        local parent = node:parent()
        table.insert(parents, 0, parent)
        node = parent
    end

    local context = {}

    for _, parent in ipairs(parents) do
        print(parent:type())
        if is_valid(parent, vim.bo.filetype) then
            local text = get_text_for_node(parent)

            if text then
                table.insert(context, text)
            end
        end
    end

    return context
end

function M.format_func(separator)
    if not separator then
        separator = ''
    end
    return utils.throttle_fn(function()
        if vim.bo.buftype ~= '' or vim.wo.previewwindow then
            return
        end

        local context = get_context()

        if #context > 0 then
            return table.concat(context, ' > ') .. separator
        end

        return ''
    end)
end

function M.debug()
    vim.keymap.set('n', 'L', function()
        print(vim.inspect(R('plugins.express_line.ts-context').format_func()()))
    end, {})
end

return M
