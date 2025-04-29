return {
    cmd = {
        'clangd',
        '--background-index',
        '--query-driver=**',
        '--clang-tidy',
        '--all-scopes-completion',
        '--cross-file-rename',
        '--completion-style=detailed',
        '--header-insertion-decorators',
        '--header-insertion=iwyu',
        '--pch-storage=memory',
        '--suggest-missing-includes',
        '--offset-encoding=utf-16',
    },
    root_markers = { 'compile_commands.json', '.clangd' },
    filetypes = { 'c', 'cpp' },
}
