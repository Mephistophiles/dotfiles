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

function telescope.multi_rg(opts)
    local conf = require('telescope.config').values
    local finders = require 'telescope.finders'
    local make_entry = require 'telescope.make_entry'
    local pickers = require 'telescope.pickers'

    local flatten = vim.tbl_flatten

    opts = opts or {}
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
    opts.shortcuts = opts.shortcuts
        or {
            ['l'] = '*.lua',
            ['v'] = '*.vim',
            ['n'] = '*.{vim,lua}',
            ['c'] = '*.c',
        }
    opts.pattern = opts.pattern or '%s'

    local custom_grep = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == '' then
                return nil
            end

            local prompt_split = vim.split(prompt, '  ')

            local args = { 'rg' }
            if prompt_split[1] then
                table.insert(args, '--regexp')
                table.insert(args, prompt_split[1])
            end

            if prompt_split[2] then
                table.insert(args, '--glob')

                local pattern
                if opts.shortcuts[prompt_split[2]] then
                    pattern = opts.shortcuts[prompt_split[2]]
                else
                    pattern = prompt_split[2]
                end

                table.insert(args, string.format(opts.pattern, pattern))
            end

            return flatten {
                args,
                { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
            }
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = 'Live Grep (with shortcuts)',
            finder = custom_grep,
            previewer = conf.grep_previewer(opts),
            sorter = require('telescope.sorters').empty(),
        })
        :find()
end

function M.mappings()
    vim.keymap.set('n', '<C-p>', function()
        telescope.find_files(themes.get_ivy {})
    end, { desc = 'Fuzzy find files in project' })
    vim.keymap.set('n', '<leader>ld', function()
        telescope.find_files(themes.get_ivy {})
    end, { desc = 'Fuzzy find files in project' })
    vim.keymap.set('n', '<C-b>', function()
        telescope.buffers(themes.get_ivy {})
    end, { desc = 'Fuzzy find opened buffers' })
    vim.keymap.set('n', '<leader>lg', function()
        telescope.multi_rg(themes.get_ivy {})
    end, { desc = 'Fuzzy find with live grep' })
    vim.keymap.set('n', '<M-/>', function()
        telescope.current_buffer_fuzzy_find(themes.get_ivy {})
    end, { desc = 'Fuzzy find in current buffer' })

    vim.keymap.set('n', '<leader>?', function()
        telescope.oldfiles(themes.get_ivy {})
    end, { desc = 'Fuzzy find recently opened files' })

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
    end, { desc = 'Fuzzy find neovim configuration files' })
end

function M.instance()
    return telescope, themes
end

function M.setup()
    M.mappings()
end

function M.config()
    require('telescope').setup {
        defaults = {
            mappings = {
                i = {
                    ['<C-Down>'] = require('telescope.actions').cycle_history_next,
                    ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
                    ['<C-u>'] = false,
                    ['<c-space>'] = function(prompt_bufnr)
                        require('telescope.actions.generate').refine(prompt_bufnr, {
                            prompt_to_prefix = true,
                            sorter = false,
                        })
                    end,
                },
            },
        },
        pickers = {
            buffers = {
                mappings = {
                    i = {
                        ['<c-d>'] = require('telescope.actions').delete_buffer,
                    },
                    n = {
                        ['<c-d>'] = require('telescope.actions').delete_buffer,
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
end

return M
