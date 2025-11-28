---@module 'telescope_selected_index.@types'
---@meta

---@alias virt_text_pos "overlay" | "right_align" | "eol"
---@alias virt_line_pos "top" | "down"

---@alias position virt_text_pos | virt_line_pos

---@class telescope_selected_index_config
---@field position position

---@class make_update_deps
---@field action_state table
---@field ns number
---@field get_picker function
---@field compute_index function
