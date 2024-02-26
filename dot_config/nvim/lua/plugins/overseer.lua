return {
    'stevearc/overseer.nvim',
    opts = {
        task_list = {
            min_width = { 100, 0.3 },
            direction = 'bottom',
        },
    },
    cmd = { 'OverseerOpen', 'OverseerRunCmd', 'OverseerRun', 'OverseerBuild', 'OverseerToggle', 'OverseerLoadBundle' },
}
