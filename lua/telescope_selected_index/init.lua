---@module 'telescope._extensions.selected_index'

local M = {}

--- Setup and return extension
--- @param ext_config telescope_selected_index_config? # Extension configuration
--- @return table # Extension table with exports
function M.setup(ext_config)
    local main = require("telescope_selected_index")
    main.config.setup(ext_config or {})

    return {
        exports = {
            selected_index = main.selected_index,
        },
    }
end

return require("telescope").register_extension({
    setup = M.setup,
})
