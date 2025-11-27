---@module 'telescope_selected_index'
local M = {}

-- Expose submodules
M.selected_index = require("telescope_selected_index.selected_index")
M.selected_index.display = {
    virt_lines = require("telescope_selected_index.display.virt_lines"),
    virt_text = require("telescope_selected_index.display.virt_text"),
}
M.config = require("telescope_selected_index.config")

--- Setup function
--- @param opts table? Optional configuration { position = "right" }
function M.setup(opts)
    opts = opts or {}
    if opts.position then
        M.config.setup({ position = opts.position })
    end

    -- Attach to all pickers automatically
    vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
            local attach_fn = M.selected_index.attach_mappings_with_selected_index()

            -- Wrapper für attach_mappings: prompt_bufnr und map werden automatisch übergeben
            local map_fn = function(prompt_bufnr, map)
                -- attach_fn muss unbedingt true/false zurückgeben
                local ok, ret = pcall(attach_fn, prompt_bufnr, map)
                if not ok then
                    vim.notify("Error in telescope_selected_index attach_fn: " .. tostring(ret), vim.log.levels.ERROR)
                    return false
                end
                return ret or true
            end

            -- Monkey-patch all builtins
            local telescope = require("telescope.builtin")
            for name, picker in pairs(telescope) do
                if type(picker) == "function" then
                    telescope[name] = function(opts_inner)
                        opts_inner = opts_inner or {}
                        local orig_attach = opts_inner.attach_mappings
                        opts_inner.attach_mappings = function(prompt_bufnr, map)
                            if orig_attach then orig_attach(prompt_bufnr, map) end
                            return map_fn(prompt_bufnr, map) -- <-- unbedingt true zurückgeben
                        end
                        return picker(opts_inner)
                    end
                end
            end
        end,
    })
end

return M
