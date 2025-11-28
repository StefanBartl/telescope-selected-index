---@module 'telescope_selected_index.update'
--- Update logic for rendering the selected index.

local M = {}

--- Factory producing the update function
---@param deps make_update_deps
---@return fun():nil
function M.make_update_selected_index(deps)
  local action_state = deps.action_state
  local ns = deps.ns
  local get_picker = deps.get_picker
  local compute_index = deps.compute_index

  return function()
    -- Try to get the selected entry; make first call to picker safe via pcall
    local ok_ent, entry = pcall(function() return action_state.get_selected_entry() end)

    -- Get picker instance
    local picker = get_picker()
    if not picker then return end

    local results_bufnr = picker.results_bufnr or (picker.manager and picker.manager.results_bufnr) or picker._results_bufnr
    if not results_bufnr or results_bufnr == 0 then return end

    -- clear previous extmarks in namespace
    vim.api.nvim_buf_clear_namespace(results_bufnr, ns, 0, -1)

    -- obtain selection row (0-based)
    local row = nil
    if type(picker.get_selection_row) == "function" then
      local r = picker.get_selection_row(picker)
      if type(r) == "number" then row = r end
    end
    if not row then
      local win = picker.results_win()
      if win and win ~= 0 then
        local ok_cur, cur = pcall(vim.api.nvim_win_get_cursor, win)
        if ok_cur and type(cur) == "table" then row = cur[1] - 1 end
      end
    end
    if not row then row = 0 end

    -- Determine index: prefer explicit entry.index when available.
    local index = nil
    if ok_ent and type(entry) == "table" and type(entry.index) == "number" then
      index = entry.index
    else
      index = compute_index and compute_index(picker, row) or (row + 1)
    end

    if not (index and index > 0) then
      return
    end

    local config = require("telescope_selected_index.config").config
    ---@type position
    local pos = config.position or "right_align"

    if pos == "overlay" or pos == "right_align" or pos == "eol" then
      ---@cast pos virt_text_pos
      require("telescope_selected_index.display.virt_text")(results_bufnr, ns, row, index, pos)
      return
    end

    if pos == "top" or pos == "down" then
      ---@cast pos virt_line_pos
      require("telescope_selected_index.display.virt_lines")(results_bufnr, ns, row, index, pos)
      return
    end

    -- Fallback: use right_align virt_text.
    require("telescope_selected_index.display.virt_text")(results_bufnr, ns, row, index, "right_align")
  end
end

return M
