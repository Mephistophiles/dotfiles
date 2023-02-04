local M = {}

function M.throttle_fn(fn)
    local recalc_after_cooldown = false
    local cooling_down = false
    local result = nil
    local function wrapped()
        if cooling_down then
            recalc_after_cooldown = true
        else
            local start = vim.loop.hrtime()
            result = fn()
            local elapsed_ms = math.floor((vim.loop.hrtime() - start) / 1e6)
            -- If this took < 2ms, we don't need a cooldown period. This prevents the context floats from flickering
            if elapsed_ms > 2 then
                cooling_down = true
                vim.defer_fn(function()
                    cooling_down = false
                    if recalc_after_cooldown then
                        recalc_after_cooldown = false
                        wrapped()
                    end
                end, 20)
            end
        end

        return result
    end
    return wrapped
end

return M
