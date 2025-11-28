---@module 'telescope_selected_index.display.virt_lines'
--- Render the current index using `virt_lines`.
---
--- This function accepts a canonical `virt_line_pos` value ("top" or "down")
--- and maps it internally to the boolean `virt_lines_above` option

---@param bufnr number        # Buffer number of the telescope results buffer.
---@param ns number           # Extmark namespace id previously created by the caller.
---@param row number          # Zero-based row in the results buffer where the index should anchor.
---@param index number        # 1-based numeric index to render above/below the row.
---@param above virt_line_pos # "top" to draw above the row, "down" to draw below.
---@return nil
return function(bufnr, ns, row, index, above)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	local virt_lines_above = (above == "top")
	local virt_line = { { tostring(index) .. ". ", "TelescopeResultsFunction" } }
	local opts = {
		virt_lines = { virt_line },
		virt_lines_above = virt_lines_above,
		hl_mode = "combine",
	}

	vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, opts)
end
