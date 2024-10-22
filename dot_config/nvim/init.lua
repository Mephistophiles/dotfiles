local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath }
        vim.fn.system { 'git', '-C', lazypath, 'checkout', 'tags/stable' } -- last stable release
    end
end
vim.opt.rtp:prepend(lazypath)

vim.g.did_load_filetypes = false
vim.g.do_filetype_lua = true

vim.filetype.add {
    extension = {
        log = 'log',
    },
}

require 'globals'
require 'news'
require 'filetype'
require 'mappings'
require 'relativenumbers'
require 'options'
require 'commands'

pcall(require, 'host')

local plugin_dirs = {
    { import = 'plugins' },
}

if vim.loop.fs_stat(vim.fn.stdpath 'config' .. '/lua/host/plugins/') then
    table.insert(plugin_dirs, { import = 'host.plugins' })
end

require('lazy').setup(plugin_dirs)
vim.cmd.colorscheme 'tokyonight-storm'

-- cleanups
vim.keymap.set('n', '<esc>', table.concat(MAP_CLEANUPS, ''), { desc = 'Clean all notifications/selections' })

-- vim.cmd('syntax on') -- On syntax
