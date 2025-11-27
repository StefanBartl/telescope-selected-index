---@module 'telescope_selected_index.update'
--- Update the virtual index overlay

local M = {}

--- make_update_selected_index
--- @param deps table
--- @return function
function M.make_update_selected_index(deps)
	local action_state = deps.action_state
	local ns = deps.ns
	local get_picker = deps.get_picker
	local compute_index = deps.compute_index

	return function()
		local ok_ent, entry = pcall(function()
			return action_state.get_selected_entry()
		end)

		local ok_p, p = pcall(get_picker)
		if not ok_p or not p then
			return
		end

		local results_bufnr = p.results_bufnr or (p.manager and p.manager.results_bufnr) or p._results_bufnr
		if not results_bufnr or results_bufnr == 0 then
			return
		end

		pcall(vim.api.nvim_buf_clear_namespace, results_bufnr, ns, 0, -1)

		local row = nil
		if type(p.get_selection_row) == "function" then
			local ok_row, r = pcall(p.get_selection_row, p)
			if ok_row then
				row = r
			end
		end
		if not row then
			local ok_win, win = pcall(function()
				return p.results_win
			end)
			if ok_win and win and win ~= 0 then
				local ok_cur, cur = pcall(vim.api.nvim_win_get_cursor, win)
				if ok_cur and type(cur) == "table" then
					row = cur[1] - 1
				end
			end
		end
		if not row then
			row = 0
		end

		local index = nil
		if ok_ent and type(entry) == "table" and type(entry.index) == "number" then
			index = entry.index
		else
			index = compute_index and compute_index(p, row) or (row + 1)
		end

		if index and index > 0 then
			local config = require("telescope_selected_index.config").config
			local pos = config.position or "right"

			if pos == "overlay" or pos == "right_align" or pos == "eol" then
                ---@diagnostic disable-next-line
				require("telescope_selected_index.display.virt_text")(results_bufnr, ns, row, index, pos)
			elseif pos == "top" then
				require("telescope_selected_index.display.virt_lines")(results_bufnr, ns, row, index, true)
			elseif pos == "down" then
				require("telescope_selected_index.display.virt_lines")(results_bufnr, ns, row, index, false)
			else
				-- fallback auf virt_text rechts
				require("telescope_selected_index.display.virt_text")(results_bufnr, ns, row, index, "right_align")
			end
		end
	end
end

return M
