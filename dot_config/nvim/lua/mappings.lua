vim.g.mapleader = ','

-- Toggle paste
vim.o.pastetoggle = '<F6>'

local function number_toggle()
    if vim.o.relativenumber then
        vim.notify('Disable relative numbers')
        vim.o.relativenumber = false
    else
        vim.notify('Enable relative numbers')
        vim.o.relativenumber = true
    end
end

local function swap_list_chars()
    if not vim.g.listchars_mode then vim.g.listchars_mode = 1 end

    if vim.g.listchars_mode == 0 then
        vim.o.list = true
        vim.g.listchars_mode = 1
        vim.notify('Enable list mode')
    elseif vim.g.listchars_mode == 1 then
        vim.opt.listchars:append({space = '·', eol = '$'})
        vim.g.listchars_mode = 2
        vim.notify('Enable verbose list mode')
    elseif vim.g.listchars_mode == 2 then
        vim.opt.listchars:remove({'space', 'eol'})
        vim.o.list = false
        vim.g.listchars_mode = 0
        vim.notify('Disable list mode')
    end
end

local function paste_git_signoff()
    local username = io.popen('git config user.name', 'r'):read('*l')
    local email = io.popen('git config user.email', 'r'):read('*l')

    vim.api.nvim_put({'Signed-off-by: ' .. username .. ' <' .. email .. '>'}, 'c', false, true)

    return true
end

local function select_word()
    local current_word = vim.fn.expand('<cword>')
    vim.o.hlsearch = true
    vim.cmd([[/\<]] .. current_word .. [[\>]])
end

-- toggle show invisible symbols
MAP.nnoremap('<F2>', function() number_toggle() end)
MAP.inoremap('<F2>', function() number_toggle() end)

MAP.nnoremap('<F4>', function() swap_list_chars() end)

-- toggle spelling
MAP.nnoremap('<F7>', [[:set spell!<CR>]])

-- Back search for f F t T
MAP.nnoremap([[\]], ',')

-- paste signoff
MAP.nnoremap('<F8>', function() paste_git_signoff() end)
MAP.inoremap('<F8>', function() paste_git_signoff() end)

-- select word on cursor
MAP.nnoremap('<leader><enter>', function() select_word() end)
-- command mode helpers
MAP.cnoremap('<C-a>', '<Home>')
MAP.cnoremap('<C-e>', '<End>')
MAP.cnoremap('<C-p>', '<Up>')
MAP.cnoremap('<C-n>', '<Down>')
MAP.cnoremap('<C-b>', '<Left>')
MAP.cnoremap('<C-f>', '<Right>')

-- map Home to buffernext, End bufferprev
MAP.nnoremap('<Home>', ':bn')
MAP.nnoremap('<End>', ':bp')

-- very magic search by default
MAP.nnoremap([[?]], [[?\v]])
MAP.nnoremap([[/]], [[/\v]])
MAP.cnoremap([[%s/]], [[%sm/]])

-- Suppress command mistakes
MAP.cmd('W', 'w')
MAP.cmd('WQ', 'wq')
MAP.cmd('Wq', 'wq')
MAP.cmd('WQA', 'wqa')
MAP.cmd('WQa', 'wqa')
MAP.cmd('Wqa', 'wqa')
MAP.cmd('Q', 'q')

-- folding
MAP.nnoremap('<space>', function()
    local current_level = vim.fn.foldlevel('.')

    if current_level > 0 then
        vim.api.nvim_input('za')
    else
        vim.api.nvim_input('<space>')
    end
end)

-- Better usage
MAP.nnoremap('Y', 'y$')
MAP.nnoremap('n', 'nzz')
MAP.nnoremap('N', 'Nzz')
MAP.vnoremap('J', [[:m '>+1<CR>gv=gv]])
MAP.vnoremap('K', [[:m '<-2<CR>gv=gv]])

-- replace paste without save in registers
MAP.vnoremap('<leader>p', '"_dP')

-- copy in clipboard
MAP.nnoremap('<leader>y', '"+y')
MAP.vnoremap('<leader>y', '"+y')
MAP.nnoremap('<leader>Y', 'gg"+yG')

-- workarounds
-- inoremap <C-c> <Esc>
MAP.inoremap('<C-c>', '<Esc>')
