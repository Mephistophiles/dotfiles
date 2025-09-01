return {
    'lewis6991/fileline.nvim',
    event = { 'BufNewFile' },
    cond = function()
        local file = vim.api.nvim_buf_get_name(0)

        if file == '' then
            return false
        end

        if not file:match '^([^:]+):([0-9:]+)$' then
            return false
        end
        return true
    end,
}
