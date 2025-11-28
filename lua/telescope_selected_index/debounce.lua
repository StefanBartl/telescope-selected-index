---@module 'telescope_selected_index.debounce'
local M = {}

--- Create debounced version of function
--- Only executes after delay_ms of inactivity
---@param fn function
---@param delay_ms number
---@return function
function M.debounce(fn, delay_ms)
    local timer = nil

    return function(...)
        local args = { ... }
        local argc = select("#", ...)

        -- Cancel previous timer
        if timer then
            vim.loop.timer_stop(timer)
        end

        -- Start new timer
        timer = vim.defer_fn(function()
            fn(unpack(args, 1, argc))
            timer = nil
        end, delay_ms)
    end
end

return M
