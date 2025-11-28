---@module 'telescope_selected_index'
local M = {}

-- Expose submodules
M.selected_index = require("telescope_selected_index.selected_index")
M.selected_index.display = {
    virt_lines = require("telescope_selected_index.display.virt_lines"),
    virt_text = require("telescope_selected_index.display.virt_text"),
}
M.config = require("telescope_selected_index.config")

local _patched = false  -- Avoid double-patching

--- Patch telescope builtins to inject selected_index
local function patch_telescope_builtins()
    if _patched then return end
    _patched = true

    local ok, telescope = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("telescope.builtin not available", vim.log.levels.WARN)
        return
    end

    local attach_fn = M.selected_index.attach_mappings_with_selected_index()

    -- Monkey-patch all builtins safely
    for name, picker in pairs(telescope) do
        if type(picker) == "function" then
            local orig_picker = picker
            telescope[name] = function(opts_inner)
                opts_inner = opts_inner or {}
                local orig_attach = opts_inner.attach_mappings
                opts_inner.attach_mappings = function(prompt_bufnr, map)
                    if orig_attach then orig_attach(prompt_bufnr, map) end
                    return attach_fn(prompt_bufnr, map)
                end
                return orig_picker(opts_inner)
            end
        end
    end
end

--- Setup function
--- @param opts telescope_selected_index_config? # Optional configuration { position = "right" }
function M.setup(opts)
    opts = opts or {}
    if opts.position then
        M.config.setup({ position = opts.position })
    end

    -- Try immediate patching if telescope is already loaded
    if package.loaded["telescope.builtin"] then
        patch_telescope_builtins()
    else
        -- Fallback: patch on first picker invocation
        vim.api.nvim_create_autocmd("User", {
            pattern = "TelescopePreviewerLoaded",
            once = true,
            callback = patch_telescope_builtins,
        })
    end
end

return M
