local plugins = require 'plugin_manager'
plugins.bootstrap()

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
plugins.setup { spec = require('plugin_usage').specs() }
vim.cmd.colorscheme 'tokyonight-storm'
