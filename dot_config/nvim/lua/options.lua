vim.opt.number = true -- Default number mode
vim.opt.relativenumber = true -- Set relative number

-- relative number only in normal mode
vim.cmd([[
augroup ToggleRelativeNumber
  au!
  autocmd InsertEnter * :setlocal norelativenumber
  autocmd InsertLeave * :setlocal relativenumber
augroup END
]])

-- highlight yanked text
vim.cmd([[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END
]])

vim.opt.tabstop = 4 -- by default 4 spaces in tab
vim.opt.shiftwidth = 4 -- by default 4 spaces in tab
vim.opt.smartindent = true -- detect indent in file

vim.opt.showmatch = true -- Set highlight for search results
vim.opt.hlsearch = true -- Highlight for search
vim.opt.incsearch = true
vim.opt.ignorecase = true -- Ignore case for search
vim.opt.smartcase = true -- turn smartcase search

-- Fish doesn't play all that well with others
vim.opt.shell = vim.fn.exepath('bash')

vim.opt.inccommand = 'nosplit'

vim.opt.wildmenu = true -- Set menu auto complete for command mode

vim.opt.cursorline = true -- Highlight current line
vim.opt.cursorcolumn = true -- Highlight current column

vim.opt.showbreak = '↳ ' -- Set text wrap symbol
vim.opt.wrap = true -- Wrap lines
vim.opt.linebreak = true -- Break lines
vim.opt.breakindent = true -- Break lines with current indent
vim.opt.cpoptions = 'Bn' -- When included, the column used for 'number' and 'relativenumber' will also be used for text of wrapped lines.

vim.opt.colorcolumn = '100,140' -- Set column for code length
vim.opt.showcmd = true -- Show incomplete commands

-- Update time in msec
vim.opt.updatetime = 500

vim.g.c_syntax_for_h = true

-- gui
vim.o.guifont = 'JetBrainsMono Nerd Font'

-- Timeout
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

-- Add new split below or right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Backups
local current_date = os.date('%Y-%m/%Y-%m-%d/')
local backupdir = vim.fn.stdpath('cache') .. '/backup/' .. current_date .. vim.fn.expand('%:p:h')

if vim.fn.isdirectory(backupdir) == 0 then vim.fn.mkdir(backupdir, 'p', '0755') end

vim.opt.backupdir = backupdir
vim.opt.backupext = os.date('.%H:%M:%S.') .. vim.fn.expand('%:e')
vim.opt.backup = true

local undodir = vim.fn.stdpath('cache') .. '/undodir/'

if vim.fn.isdirectory(undodir) == 0 then vim.fn.mkdir(undodir, 'p', '0755') end

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
vim.opt.diffopt:append({internal = true, ['algorithm:patience'] = true})

-- Show invisible
vim.opt.list = true
vim.opt.listchars = [[tab:▶ ,trail:·,extends:❯,precedes:❮]]

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menu,menuone,noselect'

vim.opt.shortmess:append({
    c = true, -- Avoid showing message extra message when using completion
})
