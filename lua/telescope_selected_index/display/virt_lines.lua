---@module 'telescope_selected_index.display.virt_lines'

---@param bufnr number
---@param ns number
---@param row number
---@param index number
---@param above virt_line_position
return function(bufnr, ns, row, index, above)
    local virt_line = { { tostring(index)..". ", "TelescopeResultsFunction" } }
    local opts = {
        virt_lines = { virt_line },
        virt_lines_above = above == true,
        hl_mode = "combine",
    }
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row, 0, opts)
end

