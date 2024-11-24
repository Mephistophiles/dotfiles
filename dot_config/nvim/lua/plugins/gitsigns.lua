return { -- Git integration for buffers
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local gitsigns = require 'gitsigns'

        -- Keep signcolumn on by default
        vim.opt.signcolumn = 'yes'

        gitsigns.setup {
            current_line_blame = true,
            update_debounce = 2500,
            attach_to_untracked = false,

            on_attach = function()
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = true })
                end

                -- Navigation
                map('n', ']c', gs.next_hunk, 'Git: Goto next hunk')
                map('n', '[c', gs.prev_hunk, 'Git: Goto prev hunk')

                -- Actions
                map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, 'Git: Stage hunk')
                map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, 'Git: Reset hunk')
                map('n', '<leader>hS', gs.stage_buffer, 'Git: Stage buffer')
                map('n', '<leader>hu', gs.undo_stage_hunk, 'Git: Undo stage hunk')
                map('n', '<leader>hR', gs.reset_buffer, 'Git: Reset buffer')
                map('n', '<leader>hP', gs.preview_hunk, 'Git: Preview hunk')
                map('n', '<leader>hp', gs.preview_hunk_inline, 'Git: Inline preview hunk')
                map('n', '<leader>hb', function()
                    gs.blame_line { full = true }
                end, 'Git: Blame line')
                map('n', '<leader>hd', gs.diffthis, 'Git: Diff this file')
                map('n', '<leader>hD', function()
                    gs.diffthis '~'
                end, 'Git: Run diff this')

                -- Text object
                map({ 'o', 'x' }, 'ih', CMD '<C-U>Gitsigns select_hunk', 'Git: Select hunk')
            end,
        }
    end,
}
