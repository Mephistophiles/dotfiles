local cache_path = vim.fn.stdpath 'cache'
local cache_file = cache_path .. '/formatter_blacklist.msgpack'

local M = {}

--- @class Blacklist
local BLACKLIST = {}

function BLACKLIST.empty() return {} end

--- Gets the current blacklist
--- @return Blacklist
function BLACKLIST.get()
    local opened, cache = pcall(vim.fn.readfile, cache_file, 'b')
    if not opened then return BLACKLIST.empty() end
    local parsed, ret = pcall(vim.fn.msgpackparse, cache)

    if parsed then
        return ret
    else
        vim.loop.fs_unlink(cache_file)
        return BLACKLIST.empty()
    end
end

--- Override current blacklist
--- @param blacklist Blacklist
function BLACKLIST.set(blacklist) vim.fn.writefile(vim.fn.msgpackdump(blacklist), cache_file, 'b') end

local filetypes = {
    c = {
        -- prettier
        function()
            local util = require('lspconfig.util')
            local filename = vim.api.nvim_buf_get_name(0)
            local project_root = util.find_git_ancestor(filename)

            if project_root and util.path.is_file(util.path.join({project_root, '.clang-format'})) then
                return {
                    exe = 'clang-format',
                    args = {},
                    stdin = true,
                    cwd = vim.fn.expand('%:p:h'), -- Run clang-format in cwd of the file.
                }
            end

            if vim.fn.executable('uncrustify') ~= 1 then return nil end

            local cfgpath = vim.fn.stdpath('config')

            return {
                exe = 'uncrustify',
                args = {'-c', cfgpath .. '/uncrustify.cfg', '-lc'},
                stdin = true,
            }
        end,
    },
    rust = {
        -- Rustfmt
        function()
            return {exe = 'rustfmt', args = {'--edition=2018', '--emit=stdout'}, stdin = true}
        end,
    },
    go = {
        -- golang
        function() return {exe = 'gofmt', stdin = true} end,
    },
    lua = {
        -- lua-format
        function()
            return {
                exe = 'lua-format',
                args = {
                    '--tab-width=4', '--column-limit=100', '--column-table-limit=100',
                    '--double-quote-to-single-quote', '--extra-sep-at-table-end',
                },
                stdin = true,
            }
        end,
    },
    cpp = {
        -- clang-format
        function()
            return {
                exe = 'clang-format',
                args = {},
                stdin = true,
                cwd = vim.fn.expand('%:p:h'), -- Run clang-format in cwd of the file.
            }
        end,
    },
    json = {
        function()
            local jq_args = {'--indent', '4'}

            if vim.b.formatter_sort_keys then table.insert(jq_args, '--sort-keys') end

            return {exe = 'jq', args = jq_args, stdin = true}
        end,
    },
}

function M.on_menu_save(blacklist) BLACKLIST.set(blacklist) end

function M.setup()
    local opts = {logging = false, filetype = filetypes}
    require('formatter').setup(opts)

    local supported_langs = {}

    for ft, fns in pairs(opts.filetype) do
        if fns[1]() ~= nil then table.insert(supported_langs, ft) end
    end

    local function blacklist_file(file)
        local blacklist = BLACKLIST.get()

        if not vim.tbl_contains(blacklist, file) then table.insert(blacklist, file) end

        BLACKLIST.set(blacklist)
    end

    local function gc_blacklist(blacklist)
        blacklist = vim.tbl_filter(function(file)
            local st = vim.loop.fs_stat(file)
            return st ~= nil -- and (st.type == 'file' or st.type == 'directory')
        end, blacklist)

        BLACKLIST.set(blacklist)

        return blacklist
    end

    local function unblacklist_file(file)
        local blacklist = BLACKLIST.get()

        blacklist = vim.tbl_filter(function(f) return f ~= file end, blacklist)

        BLACKLIST.set(blacklist)
    end

    local function is_blacklisted_file(file)
        local blacklist = BLACKLIST.get()

        for _, f in ipairs(blacklist) do if vim.startswith(file, f) then return true end end

        return false
    end

    function _G.format_document()
        local filename = vim.api.nvim_buf_get_name(0)
        local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

        if vim.b.disable_formatter == true then return end
        if not vim.tbl_contains(supported_langs, filetype) then return end
        if is_blacklisted_file(filename) then return end

        vim.cmd [[undojoin | FormatWrite]]
    end

    MAP.nnoremap('<leader>m', function()
        if not vim.b.disable_formatter then
            vim.b.disable_formatter = true
            vim.notify('Disable format on save')
        else
            vim.b.disable_formatter = false
            vim.notify('Enable format on save')
        end
    end)

    MAP.nnoremap('<leader>mb', function()
        blacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = true
        vim.notify('Permanently disable format on save')
    end)
    MAP.nnoremap('<leader>mu', function()
        unblacklist_file(vim.api.nvim_buf_get_name(0))
        vim.b.disable_formatter = false
        vim.notify('Remove current file from the blacklist')
    end)
    MAP.nnoremap('<leader>mc', function()
        local before = BLACKLIST.get()
        local after = gc_blacklist(before)
        vim.notify(string.format('GC blacklist: %d -> %d entries', #before, #after))
    end)
    MAP.nnoremap('<leader>ml',
                 function() require('settings.formatter_ui').toggle_quick_menu(BLACKLIST.get()) end)

    vim.cmd [[
        augroup FormatAutogroup
          autocmd!
          autocmd BufWritePost * :lua format_document()
        augroup END
    ]]
end

return M
