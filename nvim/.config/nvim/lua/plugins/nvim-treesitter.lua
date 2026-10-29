local supported_languages = {
    'bash',
    'c',
    'cpp',
    'cmake',
    'diff',
    'doxygen',
    'fish',
    'gitcommit',
    'go',
    'json',
    'lua',
    'log',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'regex',
    'rust',
    'vim',
    'vimdoc',
    'yaml',
}

local ts_loaded = false
local installing = {}

local function has_query(lang, name)
    -- Do not cache a missing query while its files are still being installed.
    if #vim.treesitter.query.get_files(lang, name) == 0 then
        return false
    end
    local ok, query = pcall(vim.treesitter.query.get, lang, name)
    if not ok then
        vim.notify_once('Treesitter ' .. name .. ': ' .. tostring(query), vim.log.levels.WARN)
    end
    return ok and query ~= nil
end

local function ts_load()
    -- zpack loads these plugins and applies their specs on require().
    require 'treesitter-context'

    require('rainbow-delimiters.setup').setup {
        strategy = {
            [''] = 'rainbow-delimiters.strategy.global',
        },
        query = {
            [''] = 'rainbow-delimiters',
        },
        highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow',
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
        },
    }
end

local function setup_folds(bufnr)
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        if not vim.wo[win].diff then
            vim.api.nvim_set_option_value('foldmethod', 'expr', { win = win, scope = 'local' })
            vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', { win = win, scope = 'local' })
        end
    end
end

local function ts_start(bufnr)
    if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= '' or vim.b[bufnr].bigfile then
        return
    end

    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang or not vim.list_contains(supported_languages, lang) then
        return
    end

    local function attach()
        if
            not vim.api.nvim_buf_is_loaded(bufnr)
            or vim.bo[bufnr].buftype ~= ''
            or vim.b[bufnr].bigfile
            or vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) ~= lang
        then
            return
        end

        -- start() disables regex syntax even when no highlights query exists.
        if not has_query(lang, 'highlights') then
            return
        end
        local ok, err = pcall(vim.treesitter.start, bufnr, lang)
        if not ok then
            vim.notify('Treesitter: ' .. tostring(err), vim.log.levels.WARN)
            return
        end
        require('plugin_usage').record('nvim-treesitter', 'buffer attached', 'automatic')
        -- Keep the filetype's native indenter when Treesitter has no indent query.
        if has_query(lang, 'indents') then
            local indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            if vim.bo[bufnr].indentexpr ~= indentexpr then
                vim.bo[bufnr].indentexpr = indentexpr
                local undo = vim.b[bufnr].undo_indent
                vim.b[bufnr].undo_indent = (undo and undo .. ' | ' or '') .. 'setlocal indentexpr<'
            end
        end
        vim.b[bufnr].treesitter_config_lang = lang
        setup_folds(bufnr)
        -- Optional integrations must not prevent the core buffer setup.
        if not ts_loaded then
            ts_load()
            ts_loaded = true
        end
        require('rainbow-delimiters').enable(bufnr)
    end

    local ts = require 'nvim-treesitter'
    -- The installer copies the parser before its queries. Every buffer must
    -- wait for an in-progress installation, even if the parser already exists.
    local task = installing[lang]
    if not task then
        local parser_installed = vim.list_contains(ts.get_installed('parsers'), lang)
        if parser_installed and has_query(lang, 'highlights') then
            attach()
            return
        end
        if not vim.list_contains(ts.get_available(), lang) then
            return
        end
        -- Repair partial installations: install() otherwise skips a language
        -- if either its parser or its query directory already exists.
        local partial = parser_installed or vim.list_contains(ts.get_installed('queries'), lang)
        task = ts.install({ lang }, { force = partial })
        installing[lang] = task
    end

    task:await(function(err, success)
        vim.schedule(function()
            if installing[lang] == task then
                installing[lang] = nil
            end
            if err or not success then
                vim.notify_once(
                    'Treesitter install (' .. lang .. '): ' .. tostring(err or 'failed; see :TSLog'),
                    vim.log.levels.WARN
                )
                return
            end
            attach()
        end)
    end)
end

return {
    -- Nvim Treesitter configurations and abstraction layer
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    branch = 'main',
    opts = {
        install_dir = vim.fn.stdpath 'data' .. '/site',
    },
    init = function()
        local group = vim.api.nvim_create_augroup('ConfigTreesitter', { clear = true })
        vim.api.nvim_create_autocmd('User', {
            group = group,
            pattern = 'TSUpdate',
            callback = function()
                require('nvim-treesitter.parsers').log = {
                    install_info = {
                        url = 'https://github.com/Tudyx/tree-sitter-log',
                        files = { 'src/parser.c' },
                        revision = '62cfe307e942af3417171243b599cc7deac5eab9',
                    },
                }
            end,
        })
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            callback = function(args)
                vim.schedule(function()
                    ts_start(args.buf)
                end)
            end,
            desc = 'Enable nvim-treesitter and install parser if not installed',
        })
        vim.api.nvim_create_autocmd('BufWinEnter', {
            group = group,
            callback = function(args)
                local lang = vim.b[args.buf].treesitter_config_lang
                if lang and lang == vim.treesitter.language.get_lang(vim.bo[args.buf].filetype) then
                    setup_folds(args.buf)
                end
            end,
            desc = 'Enable Treesitter folds in each window displaying the buffer',
        })
    end,
}
