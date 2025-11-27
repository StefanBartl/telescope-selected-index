---@module 'telescope_selected_index.config'

local M = {}


M.config = {
    ---@type position
    position = 'right',
}

---@param opts table { position = position }
function M.setup(opts)
    if opts.position and type(opts.position) == 'string' then
        M.config.position = opts.position or 'right'
    end
end

return M

