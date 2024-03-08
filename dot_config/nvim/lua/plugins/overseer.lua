return {
    'stevearc/overseer.nvim',
    opts = {
        task_list = {
            min_width = { 100, 0.3 },
            direction = 'bottom',
            bindings = {
                ['?'] = 'ShowHelp',
                ['g?'] = 'ShowHelp',
                ['<CR>'] = 'RunAction',
                ['<C-e>'] = 'Edit',
                ['o'] = 'Open',
                ['<C-v>'] = 'OpenVsplit',
                ['<C-s>'] = 'OpenSplit',
                ['<C-f>'] = 'OpenFloat',
                ['<C-q>'] = 'OpenQuickFix',
                ['p'] = 'TogglePreview',
                ['L'] = 'IncreaseAllDetail',
                ['H'] = 'DecreaseAllDetail',
                ['['] = 'DecreaseWidth',
                [']'] = 'IncreaseWidth',
                ['{'] = 'PrevTask',
                ['}'] = 'NextTask',
                ['q'] = 'Close',
            },
        },
    },
    cmd = { 'OverseerOpen', 'OverseerRunCmd', 'OverseerRun', 'OverseerBuild', 'OverseerToggle', 'OverseerLoadBundle' },
}
