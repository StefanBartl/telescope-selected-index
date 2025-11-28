---@module 'telescope_selected_index.selected_index'

local M = {}

local _ns_by_bufnr = {}  -- { [bufnr] = ns }
local _ns_counter = 0

--- Get or create namespace for specific results buffer
---@param results_bufnr number
---@return number
local function get_or_create_namespace(results_bufnr)
    -- Reuse existing namespace for this buffer if available
    local existing_ns = _ns_by_bufnr[results_bufnr]
    if existing_ns then
        return existing_ns
    end

    -- Create new namespace
    _ns_counter = _ns_counter + 1
    local ns = vim.api.nvim_create_namespace("telescope_selected_index_" .. tostring(_ns_counter))
    _ns_by_bufnr[results_bufnr] = ns

    return ns
end

--- Cleanup namespace tracking for buffer
---@param results_bufnr number
local function cleanup_namespace(results_bufnr)
    local ns = _ns_by_bufnr[results_bufnr]
    if ns then
        vim.api.nvim_buf_clear_namespace(results_bufnr, ns, 0, -1)
        _ns_by_bufnr[results_bufnr] = nil
    end
end

--- Lightweight helper to display the index of the currently selected Telescope entry
---@return function
function M.attach_mappings_with_selected_index()
    return function(prompt_bufnr, map)
        local action_state = require("telescope.actions.state")

        local function get_picker()
            local p = action_state.get_current_picker(prompt_bufnr)
            if p then return p end

            return nil
        end

        local picker = get_picker()
        if not picker or not picker.results_bufnr or picker.results_bufnr == 0 then
            return true
        end

        local results_bufnr = picker.results_bufnr

        -- Create unique namespace for this picker's results buffer
        local ns = get_or_create_namespace(results_bufnr)

        local compute_mod = require("telescope_selected_index.compute")
        local attach_actions = require("telescope_selected_index.actions")
        local update_mod = require("telescope_selected_index.update")

        local update_selected_index = update_mod.make_update_selected_index({
            action_state = action_state,
            ns = ns,
            get_picker = get_picker,
            compute_index = compute_mod.compute_index_from_picker,
        })

        vim.schedule(function()
            vim.defer_fn(update_selected_index, 50)
        end)

        attach_actions(map, update_selected_index)

        local augname = "TelescopeSelectedIndexAUG_" .. tostring(results_bufnr)
        local aug = vim.api.nvim_create_augroup(augname, { clear = true })
        local debounce = require("telescope_selected_index.debounce")
        local debounced_update = debounce.debounce(update_selected_index, 30)

        vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            group = aug,
            buffer = results_bufnr,
            callback = debounced_update,
        })

        -- Cleanup on buffer delete or picker close
        vim.api.nvim_create_autocmd("BufDelete", {
            buffer = results_bufnr,
            once = true,
            callback = function()
                cleanup_namespace(results_bufnr)
            end,
        })

        return true
    end
end

return M
