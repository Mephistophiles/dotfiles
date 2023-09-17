vim.bo.expandtab = true

require('lspconfig').clangd.setup(require('utils.lua').make_default_opts {
    cmd = {
        -- see clangd --help-hidden
        'clangd',
        '--background-index',
        -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
        -- to add more checks, create .clang-tidy file in the root directory
        -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
        '--clang-tidy',
        '--completion-style=bundled',
        '--cross-file-rename',
        '--header-insertion=iwyu',
    },
    capabilities = { offsetEncoding = { 'utf-16' } },
})
