vim.pack.add({ 'https://github.com/zuqini/zpack.nvim' })

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

require('zpack').setup()
vim.cmd.colorscheme 'tokyonight-storm'
