local M = {}

function M.setup()
    MAP.nnoremap([[<C-\>]], [[<cmd>Neotree reveal_force_cwd<cr>]])
    MAP.nnoremap([[<leader><leader>]], [[<cmd>Neotree reveal toggle<cr>]])
end

function M.config()
    -- Unless you are still migrating, remove the deprecated commands from v1.x
    vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

    -- If you want icons for diagnostic errors, you'll need to define them somewhere:
    vim.fn.sign_define('DiagnosticSignError', { text = ' ', texthl = 'DiagnosticSignError' })
    vim.fn.sign_define('DiagnosticSignWarn', { text = ' ', texthl = 'DiagnosticSignWarn' })
    vim.fn.sign_define('DiagnosticSignInfo', { text = ' ', texthl = 'DiagnosticSignInfo' })
    vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })
    -- NOTE: this is changed from v1.x, which used the old style of highlight groups
    -- in the form "LspDiagnosticsSignWarning"

    require('neo-tree').setup {
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        window = {
            position = 'left',
            width = 40,
            mappings = {
                ['<tab>'] = 'toggle_node',
                ['<2-LeftMouse>'] = 'open',
                ['<cr>'] = 'open',
                ['<c-s>'] = 'open_split',
                ['<c-v>'] = 'open_vsplit',
                ['<c-t>'] = 'open_tabnew',
                ['C'] = 'close_node',
                ['<bs>'] = 'navigate_up',
                ['.'] = 'set_root',
                ['H'] = 'toggle_hidden',
                ['R'] = 'refresh',
                ['/'] = 'fuzzy_finder',
                ['f'] = 'filter_on_submit',
                ['<c-x>'] = 'clear_filter',
                ['a'] = 'add',
                ['A'] = 'add_directory',
                ['d'] = 'delete',
                ['r'] = 'rename',
                ['y'] = 'copy_to_clipboard',
                ['x'] = 'cut_to_clipboard',
                ['p'] = 'paste_from_clipboard',
                ['c'] = 'copy', -- takes text input for destination
                ['m'] = 'move', -- takes text input for destination
                ['q'] = 'close_window',
                ['F'] = function()
                    require('neo-tree').show('filesystem', false)
                end,
                ['G'] = function()
                    require('neo-tree').show('git_status', false)
                end,
                ['B'] = function()
                    require('neo-tree').show('buffers', false)
                end,
            },
        },
        nesting_rules = {},
        filesystem = {
            filtered_items = {
                visible = false, -- when true, they will just be displayed differently than normal items
                hide_dotfiles = true,
                hide_gitignored = true,
                hide_by_name = {
                    '.DS_Store',
                    'thumbs.db',
                    --"node_modules"
                },
                never_show = { -- remains hidden even if visible is toggled to true
                    --".DS_Store",
                    --"thumbs.db"
                },
            },
            bind_to_cwd = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
            -- The renderer section provides the renderers that will be used to render the tree.
            --   The first level is the node type.
            --   For each node type, you can specify a list of components to render.
            --       Components are rendered in the order they are specified.
            --         The first field in each component is the name of the function to call.
            --         The rest of the fields are passed to the function as the "config" argument.
            follow_current_file = true, -- This will find and focus the file in the active buffer every
            -- time the current file is changed while the tree is open.
            hijack_netrw_behavior = 'open_current', -- netrw disabled, opening a directory opens neo-tree
            -- in whatever position is specified in window.position
            -- "open_current",  -- netrw disabled, opening a directory opens within the
            -- window like netrw would, regardless of window.position
            -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
            use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
            -- instead of relying on nvim autocmd events.
        },
        buffers = {
            show_unloaded = true,
            window = {
                mappings = {
                    ['bd'] = 'buffer_delete',
                },
            },
        },
        git_status = {
            window = {
                position = 'float',
                mappings = {
                    ['A'] = 'git_add_all',
                    ['gu'] = 'git_unstage_file',
                    ['ga'] = 'git_add_file',
                    ['gr'] = 'git_revert_file',
                    ['gc'] = 'git_commit',
                    ['gp'] = 'git_push',
                    ['gg'] = 'git_commit_and_push',
                },
            },
        },
    }
end

return M
