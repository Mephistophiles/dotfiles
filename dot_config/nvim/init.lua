local execute = vim.api.nvim_command
local fn = vim.fn

local ok, impatient = pcall(require, 'impatient')

if ok then
    impatient.enable_profile()
end

local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
    execute 'packadd packer.nvim'
end

require 'globals'
require 'mappings'
require 'options'
require 'filetypes'

pcall(require, 'host')

require 'plugins'

require('settings.rust-tools').setup()
require('settings.lspconfig').setup()
require('settings.cmp').setup()
require('settings.treesitter').setup()

if ok then
    pcall(require, 'packer_compiled')
end

-- cleanups
MAP.nnoremap('<leader><enter>', table.concat(MAP_CLEANUPS, ''))

-- vim.cmd('syntax on') -- On syntax
