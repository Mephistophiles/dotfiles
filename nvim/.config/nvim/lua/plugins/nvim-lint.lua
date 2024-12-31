vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    callback = function()
        require('lint').try_lint()
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
            append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
            args = {}, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
            stream = 'stderr', -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
            ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
            env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
            parser = parser.from_pattern(pattern, groups, severity_map, { ['source'] = 'clang-analyzer' }),
        }

        local trail_space = {
            cmd = 'echo',
            args = {},
            ignore_exitcode = true,
            parser = function(_, bufnr)
                local diagnostics = {}
                local regex = vim.regex [[\s\+$]]
                local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

                for line_number = 1, #content do
                    local line = content[line_number]
                    local start_byte, end_byte = regex:match_str(line)

                    if start_byte ~= nil then
                        table.insert(diagnostics, {
                            message = 'trailing whitespace',
                            severity = vim.diagnostic.severity.WARN,
                            lnum = line_number - 1,
                            end_lnum = line_number - 1,
                            col = start_byte,
                            end_col = end_byte,
                            source = 'trail-space',
                        })
                    end
                end

                return diagnostics
            end,
        }

        lint.linters.clang_analyzer = clang_analyzer
        lint.linters.trail_space = trail_space

        local disabled_trail_space_ft = { 'diff', 'git', 'gitcommit', 'patch', 'strace' }

        local linters_by_ft = setmetatable({
            c = { 'clang_analyzer', 'trail_space' },
            bash = { 'shellcheck', 'trail_space' },
            fish = { 'fish', 'trail_space' },
            gitcommit = { 'gitlint', 'trail_space' },
            go = { 'golangcilint', 'trail_space' },
            sh = { 'shellcheck', 'trail_space' },
        }, {
            __index = function(_, ft)
                if not vim.tbl_contains(disabled_trail_space_ft, ft) then
                    return { 'trail_space' }
                end

                return nil
            end,
        })

        lint.linters_by_ft = linters_by_ft
    end,
}
