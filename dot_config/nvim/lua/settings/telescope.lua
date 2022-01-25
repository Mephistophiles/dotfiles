local M = {}

local telescope = setmetatable({}, {
    __index = function(_, k) return require('telescope.builtin')[k] end,
})

local themes =
    setmetatable({}, {__index = function(_, k) return require('telescope.themes')[k] end})

function M.mappings()
    MAP.nnoremap('<C-p>', function() telescope.find_files(themes.get_ivy({})) end)
    MAP.nnoremap('<C-b>', function() telescope.buffers(themes.get_ivy({shorten_path = false})) end)
    MAP.nnoremap('<leader>ff', function() telescope.find_files(themes.get_ivy({})) end)
    MAP.nnoremap('<leader>fb',
                 function() telescope.buffers(themes.get_ivy({shorten_path = false})) end)
    MAP.nnoremap('<leader>fg', function() telescope.live_grep(themes.get_ivy({})) end)
    MAP.nnoremap('<leader>fw', function() telescope.grep_string(themes.get_ivy({})) end)
    MAP.nnoremap('<leader>gs', function()
        telescope.git_status {winblend = 10, border = true, previewer = false, shorten_path = false}
    end)
    MAP.nnoremap('<leader>gc', function() telescope.git_commits {winblend = 5} end)
end

function M.setup() M.mappings() end

return M
