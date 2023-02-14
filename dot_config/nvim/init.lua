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

require 'globals'
require 'filetype'
require 'mappings'
require 'relativenumbers'
require 'options'

pcall(require, 'host')

require('lazy').setup 'plugins'

-- cleanups
vim.keymap.set('n', '<leader><enter>', table.concat(MAP_CLEANUPS, ''), { desc = 'Clean all notifications/selections' })

-- vim.cmd('syntax on') -- On syntax
