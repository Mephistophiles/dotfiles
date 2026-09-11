vim.pack.add({ 'https://github.com/zuqini/zpack.nvim' })

require 'project_root'
require 'globals'
require 'filetype'
require 'mappings'
require 'relativenumbers'
require 'options'
require 'commands'
require 'lsp'
require 'statusline'

require('zpack').setup()
vim.cmd.colorscheme 'tokyonight-storm'
