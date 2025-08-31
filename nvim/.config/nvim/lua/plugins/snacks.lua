return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        explorer = { enabled = true },
        indent = { enabled = true },
    },
    keys = {
        {
            '<leader>N',
            desc = 'Neovim News',
            function()
                Snacks.win {
                    file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
                    width = 0.6,
                    height = 0.6,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = 'yes',
                        statuscolumn = ' ',
                        conceallevel = 3,
                    },
                }
            end,
        },
    },
    init = function()
        vim.api.nvim_create_autocmd('User', {
            pattern = 'VeryLazy',
            callback = function()
                local function cmd(name, fn, desc)
                    vim.api.nvim_create_user_command(name, fn, { desc = desc })
                end

                cmd('SnacksExplorer', function()
                    Snacks.explorer()
                end, 'Snacks: show explorer')

                cmd('SnacksProfiler', function()
                    Snacks.profiler.pick()
                end, 'Snacks: show profiler')

                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command
            end,
        })
    end,
}
