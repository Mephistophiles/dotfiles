-- The first vim.pack call can install every missing lockfile entry before
-- zpack has registered its build hooks. Replay Treesitter's build after setup.
local treesitter_bootstrapped = false
local bootstrap_build = vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('ConfigBootstrapBuild', { clear = true }),
    callback = function(event)
        local data = event.data
        if data.spec.name == 'nvim-treesitter' and (data.kind == 'install' or data.kind == 'update') then
            treesitter_bootstrapped = true
        end
    end,
})

vim.pack.add({ 'https://github.com/zuqini/zpack.nvim' })
vim.api.nvim_del_autocmd(bootstrap_build)

require 'project_root'
require 'globals'
require 'bigfile'
require 'filetype'
require 'mappings'
require 'relativenumbers'
require 'options'
require 'commands'
require 'trailing_whitespace'
require 'lsp'
require 'statusline'

require('plugin_usage').setup()
require('zpack').setup { spec = require('plugin_usage').specs() }
if treesitter_bootstrapped then
    vim.cmd 'ZPack build nvim-treesitter'
end
vim.cmd.colorscheme 'tokyonight-storm'
