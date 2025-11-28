---@module 'telescope_selected_index.actions'
--- Helper module that registers movement mappings for Telescope pickers.
--- This module exposes a single function (returned) which attaches a set of
--- movement mappings to the provided `map` helper. Each mapping triggers the
--- corresponding Telescope action and schedules `update_selected_index`.
--- The returned function does not return a value; it mutates the picker state
--- by registering buffer-local mappings via `map`.
---
--- Notes:
--- - `map` is the picker-local mapping helper provided by Telescope's attach_mappings.
--- - `update_selected_index` is a zero-argument function that refreshes the overlay.

---@param map function # A Telescope-provided helper for creating picker-local mappings.
---                    #   Expected signature: map(mode:string, lhs:string, fn:function) -> void
---@param update_selected_index function # Zero-argument function called after movement to refresh UI.
---@return nil
local function attach(map, update_selected_index)
    local move_mod = require("telescope_selected_index.move")
    local actions = require("telescope.actions")

    -- Insert-mode mappings
    move_mod.wrap_move(map, "<Down>", "i", actions.move_selection_next, update_selected_index)
    move_mod.wrap_move(map, "<Up>", "i", actions.move_selection_previous, update_selected_index)
    move_mod.wrap_move(map, "<C-n>", "i", actions.move_selection_next, update_selected_index)
    move_mod.wrap_move(map, "<C-p>", "i", actions.move_selection_previous, update_selected_index)

    -- Normal-mode mappings (vim-style navigation)
    move_mod.wrap_move(map, "j", "n", actions.move_selection_next, update_selected_index)
    move_mod.wrap_move(map, "k", "n", actions.move_selection_previous, update_selected_index)
    move_mod.wrap_move(map, "<Down>", "n", actions.move_selection_next, update_selected_index)
    move_mod.wrap_move(map, "<Up>", "n", actions.move_selection_previous, update_selected_index)
end

return attach
