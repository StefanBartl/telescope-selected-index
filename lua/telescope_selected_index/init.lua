---@module 'telescope_selected_index'
local M = {}

-- Expose submodules
M.selected_index = require("telescope_selected_index.selected_index")
M.selected_index.display = {
    virt_lines = require("telescope_selected_index.display.virt_lines"),
    virt_text = require("telescope_selected_index.display.virt_text"),
}
M.config = require("telescope_selected_index.config")

--- Setup function
--- @param opts telescope_selected_index_config? # Optional configuration { position = "right_align" }
function M.setup(opts)
    opts = opts or {}

    -- Apply user config
    if opts.position then
        M.config.setup({ position = opts.position })
    end

    -- Prepare attach function wrapper
    local attach_fn = M.selected_index.attach_mappings_with_selected_index()
    local function map_fn(prompt_bufnr, map)
        local ok, ret = pcall(attach_fn, prompt_bufnr, map)
        if not ok then
            vim.notify("Error in telescope_selected_index attach_fn: " .. tostring(ret), vim.log.levels.ERROR)
            return false
        end
        return ret or true
    end

    -- Monkey-patch all telescope.builtin pickers immediately
    local telescope = require("telescope.builtin")
    for name, picker in pairs(telescope) do
        if type(picker) == "function" then
            telescope[name] = function(opts_inner)
                opts_inner = opts_inner or {}
                local orig_attach = opts_inner.attach_mappings
                opts_inner.attach_mappings = function(prompt_bufnr, map)
                    if orig_attach then orig_attach(prompt_bufnr, map) end
                    return map_fn(prompt_bufnr, map)
                end
                return picker(opts_inner)
            end
        end
    end
end

return M
