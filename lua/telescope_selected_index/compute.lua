---@module 'telescope_selected_index.compute'
--- Compute helper for selected index

local M = {}

--- compute_index_from_picker
--- @param picker table|nil telescope picker instance (may be nil during early picker lifecycle)
--- @param row number zero-based row in the results buffer
--- @return number index 1-based index (best-effort)
function M.compute_index_from_picker(picker, row)
  -- Defensive checks: prefer picker.results, then manager.results, then fallback.
  local results = nil
  if picker == nil then
    return row + 1
  end

  if type(picker.results) == "table" and #picker.results > 0 then
    results = picker.results
  elseif picker.manager and type(picker.manager.results) == "table" and #picker.manager.results > 0 then
    results = picker.manager.results
  elseif picker._results and type(picker._results) == "table" and #picker._results > 0 then
    results = picker._results
  end

  if not results then
    -- fallback: assume contiguous rows -> row + 1
    return row + 1
  end

  -- Count non-nil entries up to the given row (pragmatic heuristic).
  local count = 0
  local upto = math.min(row + 1, #results)
  for i = 1, upto do
    if results[i] ~= nil then
      count = count + 1
    end
  end
  if count == 0 then
    return row + 1
  end
  return count
end


return M
