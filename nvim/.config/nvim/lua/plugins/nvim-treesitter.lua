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
        vim.wo[win].foldmethod = 'expr'
        vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
end

local function ts_start(bufnr)
    if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= '' then
        return
    end

    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang or not vim.list_contains(supported_languages, lang) then
        return
    end

    local function attach()
        if
            not vim.api.nvim_buf_is_loaded(bufnr)
            or vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) ~= lang
        then
            return
        end

        local ok, err = pcall(vim.treesitter.start, bufnr, lang)
        if not ok then
            vim.notify('Treesitter: ' .. tostring(err), vim.log.levels.WARN)
            return
        end
        if not ts_loaded then
            ts_load()
            ts_loaded = true
        end
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.b[bufnr].treesitter_config_lang = lang
        setup_folds(bufnr)
        require('rainbow-delimiters').enable(bufnr)
    end

    local ts = require 'nvim-treesitter'
    if vim.list_contains(ts.get_installed('parsers'), lang) then
        attach()
        return
    end
    if not vim.list_contains(ts.get_available(), lang) then
        return
    end

    installing[lang] = installing[lang] or ts.install { lang }
    installing[lang]:await(function(err)
        vim.schedule(function()
            installing[lang] = nil
            if err then
                vim.notify('Treesitter install: ' .. tostring(err), vim.log.levels.WARN)
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
