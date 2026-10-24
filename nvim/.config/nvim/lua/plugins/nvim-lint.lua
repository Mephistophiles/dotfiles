vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('ConfigLint', { clear = true }),
    pattern = '*',
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if vim.bo[args.buf].buftype ~= '' or vim.b[args.buf].bigfile then
            return
        end
        if vim.tbl_contains({ 'c', 'bash', 'fish', 'gitcommit', 'go', 'sh' }, ft) then
            vim.api.nvim_buf_call(args.buf, function()
                require('plugin_usage').record('nvim-lint', 'lint request', 'automatic')
                require('lint').try_lint()
            end)
        end
    end,
})

return {
    'mfussenegger/nvim-lint',
    lazy = true,
    config = function()
        local lint = require 'lint'
        local parser = require 'lint.parser'

        local pattern = [[([^:]*):(%d+):(%d+): (%w+): ([^[]+)]]
        local groups = { 'file', 'lnum', 'col', 'severity', 'message' }

        local severity_map = {
            ['fatal_error'] = vim.diagnostic.severity.ERROR,
            ['error'] = vim.diagnostic.severity.ERROR,
            ['warning'] = vim.diagnostic.severity.WARN,
            ['information'] = vim.diagnostic.severity.INFO,
            ['hint'] = vim.diagnostic.severity.HINT,
            ['note'] = vim.diagnostic.severity.HINT,
        }

        ---
        ---@class lint.Linter
        local clang_analyzer = {
            cmd = 'clang-analyzer',
            append_fname = true,    -- Automatically append the file name to `args` if `stdin = false` (default: true)
            args = {},              -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
            stream = 'stderr',      -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
            ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
            env = nil,              -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
            parser = parser.from_pattern(pattern, groups, severity_map, { ['source'] = 'clang-analyzer' }),
        }

        lint.linters.clang_analyzer = clang_analyzer
        lint.linters_by_ft = {
            c = { 'clang_analyzer' },
            bash = { 'shellcheck' },
            fish = { 'fish' },
            gitcommit = { 'gitlint' },
            go = { 'golangcilint' },
            sh = { 'shellcheck' },
        }
    end,
}
