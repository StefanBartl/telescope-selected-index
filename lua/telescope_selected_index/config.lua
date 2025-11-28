---@module 'telescope_selected_index.config'
--- Configuration module for telescope_selected_index.

local M = {}

---@type telescope_selected_index_config
M.config = {
  -- default canonical value used by display code
  position = "right_align",
}

--- Validate and normalize a user-provided position value.
--- Accepts legacy synonyms (e.g. "right" for "right_align") and returns a safe value.
--- @param pos any
--- @return position
local function normalize_position(pos)
  if type(pos) ~= "string" then
    return M.config.position
  end

  -- normalize common synonyms
  if pos == "right" then
    pos = "right_align"
  end

  -- allowed values set
  local allowed = {
    overlay = true,
    right_align = true,
    eol = true,
    top = true,
    down = true,
  }

  if allowed[pos] then
    return pos
  end

  -- fallback to default if unknown
  return M.config.position
end

--- Setup configuration
--- @param opts table # { position = position }?
function M.setup(opts)
  opts = opts or {}
  if opts.position ~= nil then
    if type(opts.position) == "string" then
      M.config.position = normalize_position(opts.position)
    end
    -- non-string values are ignored and the default is kept
  end
end


return M
