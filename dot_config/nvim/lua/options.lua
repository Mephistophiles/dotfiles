-- highlight yanked text
local highlight_yank_group = vim.api.nvim_create_augroup('highlight_yank', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    group = highlight_yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 700 }
    end,
})

vim.opt.tabstop = 4 -- by default 4 spaces in tab
vim.opt.shiftwidth = 4 -- by default 4 spaces in tab
vim.opt.smartindent = true -- detect indent in file

vim.opt.showmatch = true -- Set highlight for search results
vim.opt.hlsearch = true -- Highlight for search
vim.opt.incsearch = true
vim.opt.ignorecase = true -- Ignore case for search
vim.opt.smartcase = true -- turn smartcase search

-- Fish doesn't play all that well with others
vim.opt.shell = vim.fn.exepath 'bash'

vim.opt.inccommand = 'split' -- split preview for replace preview

vim.opt.wildmenu = true -- Set menu auto complete for command mode

vim.opt.cursorline = true -- Highlight current line
vim.opt.cursorcolumn = true -- Highlight current column

vim.opt.showbreak = '↳ ' -- Set text wrap symbol
vim.opt.wrap = true -- Wrap lines
vim.opt.linebreak = true -- Break lines
vim.opt.breakindent = true -- Break lines with current indent
vim.opt.cpoptions = 'Bn' -- When included, the column used for 'number' and 'relativenumber' will also be used for text of wrapped lines.

vim.opt.colorcolumn = { 80, 100 } -- Set column for code length
vim.opt.showcmd = true -- Show incomplete commands

-- Update time in msec
vim.opt.updatetime = 500

vim.g.c_syntax_for_h = true

-- gui
vim.o.guifont = 'FiraCode Nerd Font Mono:h10'

-- Timeout
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

-- Add new split below or right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Backups
local current_date = os.date '%Y-%m/%Y-%m-%d/'
local backupdir = vim.fn.stdpath 'cache' .. '/backup/' .. current_date .. vim.fn.expand '%:p:h'

if vim.fn.isdirectory(backupdir) == 0 then
    vim.fn.mkdir(backupdir, 'p', '0755')
end

vim.opt.backupdir = backupdir
vim.opt.backupext = os.date '.%H:%M:%S.' .. vim.fn.expand '%:e'
vim.opt.backup = true

local undodir = vim.fn.stdpath 'cache' .. '/undodir/'

if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, 'p', '0755')
end

vim.opt.undofile = true
vim.opt.undodir = undodir

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Extra Vimrc
vim.opt.exrc = true

-- Disable unsafe commands for extra vimrc
vim.opt.secure = true

-- Langmap Russian
vim.opt.langmap =
    [[ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz]]
-- Spell check
vim.opt.spelllang = 'en_us,ru_ru'

-- better diffopt
vim.opt.diffopt:append { internal = true, ['algorithm:patience'] = true }

-- Show invisible
vim.opt.list = true
vim.opt.listchars:append {
    space = '·',
    trail = '·',
    extends = '❯',
    precedes = '❮',
}

vim.keymap.set('n', '<F4>', function()
    local indent_blankline_commands = require 'indent_blankline.commands'
    local current_mode = vim.g.listchars_mode or 'Full'
    -- {"Off", "Partial", "Full"}
    if current_mode == 'Off' then
        vim.opt.list = true
        vim.g.listchars_mode = 'Partial'
    elseif current_mode == 'Partial' then
        vim.opt.listchars:append { space = '·', eol = '↴' }
        vim.g.listchars_mode = 'Full'
    elseif current_mode == 'Full' then
        vim.opt.list = false
        vim.opt.listchars:remove { 'space', 'eol' }
        vim.g.listchars_mode = 'Off'
    end

    if vim.g.listchars_mode == 'Full' and not vim.g.indent_blankline_enabled then
        indent_blankline_commands.enable(true)
    elseif vim.g.listchars_mode ~= 'Full' and vim.g.indent_blankline_enabled then
        indent_blankline_commands.disable(true)
    end
    indent_blankline_commands.refresh(true)

    vim.notify('Current list mode: ' .. vim.g.listchars_mode)
end, { desc = 'Show/Hide whitespaces' })

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menu,menuone,noselect'

vim.opt.shortmess:append {
    c = true, -- Avoid showing message extra message when using completion
}
