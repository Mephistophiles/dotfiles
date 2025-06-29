local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
    if not vim.uv.fs_stat(lazypath) then
        vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath }
        vim.fn.system { 'git', '-C', lazypath, 'checkout', 'tags/stable' } -- last stable release
    end
end
vim.opt.rtp:prepend(lazypath)

require 'project_root'
require 'globals'
require 'filetype'
require 'mappings'
require 'relativenumbers'
require 'options'
require 'commands'
require 'lsp'

pcall(require, 'host')

local plugin_dirs = {
    { import = 'plugins' },
}

if vim.loop.fs_stat(vim.fn.stdpath 'config' .. '/lua/host/plugins/') then
    table.insert(plugin_dirs, { import = 'host.plugins' })
end

require('lazy').setup(plugin_dirs)
vim.cmd.colorscheme 'tokyonight-storm'
