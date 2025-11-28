---@module 'telescope_selected_index.cache'
--- Simple incremental cache for counting non-nil entries in a results table.
--- Purpose: reduce repeated full scans by remembering how many non-nil entries were seen up to 'cached_upto'.

local M = {}

-- store cache by results table identity (tostring(tbl) used as key)
M._cache = {}  -- { [key] = { results_ref = tbl, cached_upto = number, cached_count = number, len_snapshot = number } }

local function key_for(tbl)
  return tostring(tbl)
end

--- Reset cache entry for a given results table (or all)
--- @param tbl table|nil
function M.reset(tbl)
  if not tbl then
    M._cache = {}
    return
  end
  local k = key_for(tbl)
  M._cache[k] = nil
end

--- Get non-nil count up to `upto` (1-based) for `results` table, using incremental caching.
--- Returns count (number) and a boolean `from_cache` indicating whether the value came fully from cache or was partially computed.
--- @param results table
--- @param upto number # 1-based inclusive index to count up to
--- @return number, boolean
function M.count_upto(results, upto)
  if type(results) ~= "table" then
    return 0, false
  end
  local k = key_for(results)
  local entry = M._cache[k]

  local results_len = #results
  if not entry then
    -- create cache entry
    entry = { results_ref = results, cached_upto = 0, cached_count = 0, len_snapshot = results_len }
    M._cache[k] = entry
  else
    -- if table object changed (very unlikely) or length changed dramatically, reset
    if entry.results_ref ~= results then
      entry = { results_ref = results, cached_upto = 0, cached_count = 0, len_snapshot = results_len }
      M._cache[k] = entry
    end
  end

  -- normalize upto to not exceed length of table
  local target = math.min(upto, results_len)
  if target <= 0 then
    return 0, false
  end

  -- If cached covers target exactly, return cached_count
  if entry.cached_upto >= target then
    -- cached value covers the requested range; however cached_count is the count up to cached_upto
    -- recompute if cached_upto > target (rare)
    return entry.cached_count, true
  end

  -- If we need to compute forward only from cached_upto+1 to target
  local start_idx = entry.cached_upto + 1
  local count = entry.cached_count

  -- Bound check
  local upto_idx = target
  for i = start_idx, upto_idx do
    if results[i] ~= nil then
      count = count + 1
    end
  end

  -- Update cache state
  entry.cached_upto = upto_idx
  entry.cached_count = count
  entry.len_snapshot = results_len

  -- store back
  M._cache[k] = entry
  return count, false
end

return M
