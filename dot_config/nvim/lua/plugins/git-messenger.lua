return { -- Vim and Neovim plugin to reveal the commit messages under the cursor
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger' },
    keys = { { '<leader>gm', '<Plug>(git-messenger)', desc = 'GitMessenger: show git commit' } },
}
