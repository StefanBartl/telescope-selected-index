---@module 'telescope_selected_index.compute'
--- Compute helper for selected index

local M = {}

local cache = require("telescope_selected_index.cache")

--- compute index for selected entry from picker
--- @param picker table|nil # telescope picker instance (may be nil during early picker lifecycle)
--- @param row number # zero-based row in the results buffer
--- @return number # index 1-based index (best-effort)
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
  local upto = math.min(row + 1, #results)

  -- Use incremental cache to count non-nil entries up to `upto`.
  local ok, count = pcall(function()
    return cache.count_upto(results, upto)
  end)
  if not ok or type(count) ~= "number" then
    -- fallback to full scan
    local c = 0
    for i = 1, upto do
      if results[i] ~= nil then c = c + 1 end
    end
    if c == 0 then
      return row + 1
    end
    return c
  end

  if count == 0 then
    return row + 1
  end
  return count
end

return M
