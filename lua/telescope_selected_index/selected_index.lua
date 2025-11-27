---@module 'telescope_selected_index.selected_index'
--- Lightweight helper to display the index of the currently selected Telescope entry
--- as an inline virtual text overlay in the results window.

local M = {}

--- attach_mappings_with_selected_index
--- Returns a function suitable for passing to Telescope's `attach_mappings`.
function M.attach_mappings_with_selected_index()
    return function(prompt_bufnr, map)
        local action_state = require("telescope.actions.state")
        local actions = require("telescope.actions")

        local ns = vim.api.nvim_create_namespace("telescope_selected_index_ns")

        local function get_picker()
            local ok, p = pcall(action_state.get_current_picker, prompt_bufnr)
            if ok and p then return p end
            local ok2, p2 = pcall(action_state.get_current_picker)
            if ok2 and p2 then return p2 end
            return nil
        end

        local compute_mod = require("telescope_selected_index.compute")
        local move_mod = require("telescope_selected_index.move")
        local update_mod = require("telescope_selected_index.update")

        local update_selected_index = update_mod.make_update_selected_index({
            action_state = action_state,
            ns = ns,
            get_picker = get_picker,
            compute_index = compute_mod.compute_index_from_picker,
        })

        vim.schedule(update_selected_index)
        vim.defer_fn(update_selected_index, 40)
        vim.defer_fn(update_selected_index, 500)

        move_mod.wrap_move(map, "<Down>", "i", actions.move_selection_next, update_selected_index)
        move_mod.wrap_move(map, "<Up>", "i", actions.move_selection_previous, update_selected_index)
        move_mod.wrap_move(map, "<C-n>", "i", actions.move_selection_next, update_selected_index)
        move_mod.wrap_move(map, "<C-p>", "i", actions.move_selection_previous, update_selected_index)
        move_mod.wrap_move(map, "j", "n", actions.move_selection_next, update_selected_index)
        move_mod.wrap_move(map, "k", "n", actions.move_selection_previous, update_selected_index)
        move_mod.wrap_move(map, "<Down>", "n", actions.move_selection_next, update_selected_index)
        move_mod.wrap_move(map, "<Up>", "n", actions.move_selection_previous, update_selected_index)

        local ok, p = pcall(get_picker)
        if ok and p and p.results_bufnr and p.results_bufnr ~= 0 then
            local augname = "TelescopeSelectedIndexAUG_" .. tostring(p.results_bufnr)
            local aug = vim.api.nvim_create_augroup(augname, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorMoved" }, {
                group = aug,
                buffer = p.results_bufnr,
                callback = function()
                    vim.schedule(update_selected_index)
                end,
            })
        end

        return true
    end
end

return M
