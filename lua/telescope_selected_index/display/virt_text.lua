---@module 'telescope_selected_index.display.virt_text'
--- Render the current index using extmarks with `virt_text`.
---
--- The function accepts a canonical `virt_text_pos` value and applies it
--- to `virt_text_pos` option when setting an extmark. This file uses

---@param results_bufnr number     # Buffer number of the telescope results buffer.
---@param ns number                # Extmark namespace id previously created by the caller.
---@param row number               # Zero-based row in the results buffer where the index should be displayed.
---@param index number             # 1-based numeric index to render.
---@param text_align virt_text_pos # One of "overlay"|"right_align"|"eol".
---@return nil
return function(results_bufnr, ns, row, index, text_align)
  local virt_text = { { tostring(index) .. ". ", "TelescopeResultsFunction" } }
  local opts = {
    virt_text = virt_text,
    hl_mode = "combine",
    virt_text_pos = text_align,
  }

  pcall(vim.api.nvim_buf_set_extmark, results_bufnr, ns, row, 0, opts)
end
