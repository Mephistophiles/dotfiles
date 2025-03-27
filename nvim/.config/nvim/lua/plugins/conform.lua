local supported_languages = {
    c = { 'clang_format' },
    go = { 'gofmt' },
    json = { 'jq' },
    lua = { 'stylua' },
    rust = { 'rustfmt' },
}

vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = vim.tbl_keys(supported_languages),
    callback = function(event)
        require('formatter').attach_formatter(nil, event.buf)
    end,
})

return {
    'stevearc/conform.nvim',
    lazy = true,
    cmd = { 'ConformInfo' },

    config = function()
        local conform = require 'conform'
        local util = require 'conform.util'

        conform.setup {
            formatters_by_ft = supported_languages,
            formatters = {
                clang_format = {
                    condition = function()
                        return util.root_file { '.clang-format' } ~= nil
                    end,
                },
                jq = { args = { '--indent', '4' } },
            },
        }
    end,
}
