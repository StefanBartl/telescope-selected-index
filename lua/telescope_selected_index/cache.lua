---@module 'telescope_selected_index.cache'
--- Simple incremental cache for counting non-nil entries in a results table.
--- Purpose: reduce repeated full scans by remembering how many non-nil entries were seen up to 'cached_upto'.

local M = {}

-- Store cache by results table identity (weak keys for automatic GC)
M._cache = setmetatable({}, { __mode = "k" })

--- Reset cache entry for a given results table (or all)
---@param tbl table|nil
function M.reset(tbl)
    if not tbl then
        M._cache = setmetatable({}, { __mode = "k" })
        return
    end
    M._cache[tbl] = nil
end

--- Get non-nil count up to `upto` (1-based) for `results` table, using incremental caching.
--- Returns count (number) and a boolean `from_cache` indicating whether the value came fully from cache or was partially computed.
---@param results table
---@param upto number # 1-based inclusive index to count up to
---@return number, boolean
function M.count_upto(results, upto)
    if type(results) ~= "table" then
        return 0, false
    end

    local entry = M._cache[results]
    local results_len = #results

    if not entry then
        -- Create cache entry
        entry = {
            cached_upto = 0,
            cached_count = 0,
            len_snapshot = results_len
        }
        M._cache[results] = entry
    else
        -- Length change detection (might indicate table mutation)
        if entry.len_snapshot ~= results_len then
            entry.len_snapshot = results_len
            -- reset if length decreased significantly
            if results_len < entry.cached_upto then
                entry.cached_upto = 0
                entry.cached_count = 0
            end
        end
    end

    -- Normalize upto to not exceed length of table
    local target = math.min(upto, results_len)
    if target <= 0 then
        return 0, false
    end

    -- If cached covers target exactly, return cached_count
    if entry.cached_upto >= target then
        return entry.cached_count, true
    end

    -- Compute forward only from cached_upto+1 to target
    local start_idx = entry.cached_upto + 1
    local count = entry.cached_count

    for i = start_idx, target do
        if results[i] ~= nil then
            count = count + 1
        end
    end

    -- Update cache state
    entry.cached_upto = target
    entry.cached_count = count
    entry.len_snapshot = results_len

    -- Store back (actually not needed since entry is a reference)
    M._cache[results] = entry

    return count, false
end

return M
