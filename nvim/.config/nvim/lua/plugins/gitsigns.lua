return { -- Git integration for buffers
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    config = function()
        local gitsigns = require 'gitsigns'

        -- Keep signcolumn on by default
        vim.opt.signcolumn = 'yes'

        gitsigns.setup {
            current_line_blame = true,
            update_debounce = 2500,
            attach_to_untracked = false,

            on_attach = function(bufnr)
                if vim.b[bufnr].bigfile then
                    return false
                end
                require('plugin_usage').record('gitsigns.nvim', 'buffer attached', 'automatic')
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc)
                    local tracked = function(...)
                        require('plugin_usage').record('gitsigns.nvim', desc, 'manual')
                        return rhs(...)
                    end
                    -- String mappings retain their original operator behavior.
                    if type(rhs) == 'string' then
                        tracked = ('<Cmd>lua require("plugin_usage").record("gitsigns.nvim", %q)<CR>'):format(desc) .. rhs
                    end
                    vim.keymap.set(mode, lhs, tracked, { desc = desc, buf = bufnr })
                end

                -- Navigation
                map('n', ']c', function()
                    gs.nav_hunk 'next'
                end, 'Git: Goto next hunk')
                map('n', '[c', function()
                    gs.nav_hunk 'prev'
                end, 'Git: Goto prev hunk')

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk, 'Git: Stage hunk')
                map('n', '<leader>hr', gs.reset_hunk, 'Git: Reset hunk')
                map('x', '<leader>hs', function()
                    gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, 'Git: Stage selected lines')
                map('x', '<leader>hr', function()
                    gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, 'Git: Reset selected lines')
                map('n', '<leader>hS', gs.stage_buffer, 'Git: Stage buffer')
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
                map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Git: Select hunk')
            end,
        }
    end,
}
