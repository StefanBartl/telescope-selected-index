---@module 'telescope_selected_index.display.virt_text'
--- Render index using extmarks with virt_text

---@param results_bufnr number
---@param ns number
---@param row number
---@param index number
---@param text_align virt_text_pos
---@return nil
return function(results_bufnr, ns, row, index, text_align)
	if not vim.api.nvim_buf_is_valid(results_bufnr) then
		return false
	end

	local line_count = vim.api.nvim_buf_line_count(results_bufnr)
	if row < 0 or row >= line_count then
		return false
	end

	if type(index) ~= "number" or index < 1 then
		return false
	end

	local virt_text = { { tostring(index) .. ". ", "TelescopeResultsFunction" } }
	local opts = {
		virt_text = virt_text,
		hl_mode = "combine",
		virt_text_pos = text_align,
	}

	vim.api.nvim_buf_set_extmark(results_bufnr, ns, row, 0, opts)
end
