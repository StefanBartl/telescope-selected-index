---@module 'telescope_selected_index.move'
--- Movement helper for attaching update functions to keys

local M = {}

--- Movement helper for attaching update functions to keys
---@param map function
---@param key string
---@param mode string
---@param action_fn function
---@param update_fn function
---@return boolean|nil
function M.wrap_move(map, key, mode, action_fn, update_fn)
    map(mode, key, function(prompt_bufnr_)
        pcall(action_fn, prompt_bufnr_)
        if type(update_fn) == "function" then
            vim.schedule(update_fn)
        end
        return true
    end)
end

return M
