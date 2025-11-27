---@module 'telescope_selected_index.display.virt_text'

---@param results_bufnr number
---@param ns number
---@param row number
---@param index number
---@param text_align virt_text_pos
return function(results_bufnr, ns, row, index, text_align)
    local virt_text = { { tostring(index)..". ", "TelescopeResultsFunction" } }
    local opts = {
        virt_text = virt_text,
        hl_mode = "combine",
        virt_text_pos = text_align,
    }
    pcall(vim.api.nvim_buf_set_extmark, results_bufnr, ns, row, 0, opts)
end
