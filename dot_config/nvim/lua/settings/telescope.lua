local M = {}

local telescope = setmetatable({}, {
    __index = function(_, k)
        return require('telescope.builtin')[k]
    end,
})

local themes = setmetatable({}, {
    __index = function(_, k)
        return require('telescope.themes')[k]
    end,
})

function M.mappings()
    local function add_search_previewer(opts)
        return vim.tbl_deep_extend('force', opts, {
            previewer = true,
        })
    end
    local function add_search_refine(opts)
        return vim.tbl_deep_extend('force', opts, {
            mappings = {
                i = {
                    ['<c-space>'] = function(prompt_bufnr)
                        require('telescope.actions.generate').refine(prompt_bufnr, {
                            prompt_to_prefix = true,
                            sorter = false,
                        })
                    end,
                },
            },
        })
    end
    vim.keymap.set('n', '<C-p>', function()
        telescope.find_files(add_search_refine(themes.get_ivy {}))
    end, { desc = 'Fuzzy find files in project' })
    vim.keymap.set('n', '<C-b>', function()
        telescope.buffers(add_search_refine(themes.get_ivy {}))
    end, { desc = 'Fuzzy find opened buffers' })
    vim.keymap.set('n', '<leader>lg', function()
        telescope.live_grep(add_search_refine(themes.get_ivy {}))
    end, { desc = 'Fuzzy find with live grep' })
    vim.keymap.set('n', '<M-/>', function()
        telescope.current_buffer_fuzzy_find(add_search_refine(add_search_previewer(themes.get_ivy {})))
    end, { desc = 'Fuzzy find in current buffer' })

    vim.keymap.set('n', '<leader>en', function()
        local opts_with_preview, opts_without_preview
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        local set_prompt_to_entry_value = function(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            if not entry or not type(entry) == 'table' then
                return
            end

            action_state.get_current_picker(prompt_bufnr):reset_prompt(entry.ordinal)
        end

        opts_with_preview = {
            prompt_title = '~ dotfiles ~',
            shorten_path = false,
            cwd = '~/.config/nvim',

            layout_strategy = 'flex',
            layout_config = {
                width = 0.9,
                height = 0.8,

                horizontal = { width = { padding = 0.15 } },
                vertical = { preview_height = 0.75 },
            },

            mappings = { i = { ['<C-y>'] = false } },

            attach_mappings = function(_, map)
                map('i', '<c-y>', set_prompt_to_entry_value)
                map('i', '<M-c>', function(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    vim.schedule(function()
                        require('telescope.builtin').find_files(opts_without_preview)
                    end)
                end)

                return true
            end,
        }

        opts_without_preview = vim.deepcopy(opts_with_preview)
        opts_without_preview.previewer = false

        require('telescope.builtin').find_files(opts_with_preview)
    end, { desc = 'Fuzzy find neovim configuration files' })
end

function M.instance()
    return telescope, themes
end

function M.setup()
    M.mappings()
end

return M
