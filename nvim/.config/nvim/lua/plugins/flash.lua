return {
    'folke/flash.nvim',
    ---@type Flash.Config
    opts = { modes = { search = { enabled = false }, char = { enabled = false } } },
    keys = {
        {
            ';',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump {}
            end,
            desc = 'Flash: motion',
        },
        {
            '<leader>fs',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump { mode = 'fuzzy' }
            end,
            desc = 'Flash: motion',
        },
        {
            '<leader>fc',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').jump { continue = true }
            end,
            desc = 'Flash: continue motion',
        },
        {
            '<leader>fw',
            mode = { 'n', 'x', 'o' },
            function()
                local Flash = require 'flash'

                ---@param opts Flash.Format
                local function format_first_match(opts)
                    -- always show first and second label
                    return {
                        { opts.match.label1, opts.hl_group },
                        { opts.match.label2, opts.hl_group },
                    }
                end

                local function format_second_match(opts)
                    return {
                        { opts.match.label2, opts.hl_group },
                    }
                end

                Flash.jump {
                    search = { mode = 'search' },
                    label = { after = false, before = { 0, 0 }, uppercase = false, format = format_first_match },
                    pattern = [[\<]],
                    action = function(match, state)
                        state:hide()
                        Flash.jump {
                            search = { max_length = 0 },
                            highlight = { matches = false },
                            label = { after = { 0, 2 }, format = format_second_match },
                            matcher = function(win)
                                -- limit matches to the current label
                                return vim.tbl_filter(function(m)
                                    return m.label == match.label and m.win == win
                                end, state.results)
                            end,
                            labeler = function(matches)
                                for _, m in ipairs(matches) do
                                    m.label = m.label2 -- use the second label
                                end
                            end,
                        }
                    end,
                    labeler = function(matches, state)
                        local labels = state:labels()
                        for m, match in ipairs(matches) do
                            match.label1 = labels[math.floor((m - 1) / #labels) + 1]
                            match.label2 = labels[(m - 1) % #labels + 1]
                            match.label = match.label1
                        end
                    end,
                }
            end,
            desc = 'Flash: 2 char hop motion',
        },
        {
            '<leader>fv',
            mode = { 'n', 'x', 'o' },
            function()
                require('flash').treesitter()
            end,
            desc = 'Flash: Treesitter',
        },
        {
            'r',
            mode = 'o',
            function()
                require('flash').remote()
            end,
            desc = 'Flash: remote motion',
        },
        {
            'R',
            mode = { 'o', 'x' },
            function()
                require('flash').treesitter_search()
            end,
            desc = 'Flash: treesitter search',
        },
        {
            '<leader>fs',
            mode = { 'c' },
            function()
                require('flash').toggle()
            end,
            desc = 'Flash: toggle flash search',
        },
    },
}
