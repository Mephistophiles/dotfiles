local utils = require 'plugins.telescope.utils'

return { -- Find, Filter, Preview, Pick. All lua, all the time.
    'nvim-telescope/telescope.nvim',
    module = 'telescope',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
        'nvim-telescope/telescope-project.nvim',
        'debugloop/telescope-undo.nvim',
    },
    init = function()
        local telescope, themes = utils.instance()
        local key = function(key, fn, desc)
            vim.keymap.set('n', key, fn, { desc = 'Telescope: ' .. desc })
        end

        key('<leader>u', CMD 'Telescope undo', 'Show undo history')

        key('<C-p>', function()
            telescope.find_files(themes.get_ivy {})
        end, 'Fuzzy find files in project')
        key('<leader>ld', function()
            telescope.find_files(themes.get_ivy {})
        end, 'Fuzzy find files in project')
        key('<C-b>', function()
            telescope.buffers(themes.get_ivy {})
        end, 'Fuzzy find opened buffers')
        key('<leader>lg', function()
            telescope.multi_rg(themes.get_ivy {})
        end, 'Fuzzy find with live grep')
        key('<M-/>', function()
            telescope.current_buffer_fuzzy_find(themes.get_ivy {})
        end, 'Fuzzy find in current buffer')

        key('<leader>?', function()
            telescope.oldfiles(themes.get_ivy {})
        end, 'Fuzzy find recently opened files')

        key('<leader>en', function()
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

                mappings = {
                    i = {
                        ['<C-y>'] = false,
                    },
                },

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
        end, 'Fuzzy find neovim configuration files')
    end,
    config = function()
        local actions = require('telescope.actions')
        require('telescope').setup {
            defaults = {
                mappings = {
                    i = {
                        ['<C-Down>'] = actions.cycle_history_next,
                        ['<C-Up>'] = actions.cycle_history_prev,
                        ['<C-u>'] = false,
                        ['<C-space>'] = actions.to_fuzzy_refine,
                    },
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        i = {
                            ['<c-d>'] = actions.delete_buffer,
                        },
                        n = {
                            ['<c-d>'] = actions.delete_buffer,
                        },
                    },
                },
                current_buffer_fuzzy_find = {
                    previewer = true,
                },
            },
        }
        require('telescope').load_extension 'project'
        require('telescope').load_extension 'ui-select'
        require('telescope').load_extension 'undo'
    end,
}
