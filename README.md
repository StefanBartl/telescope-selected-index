# telescope-selected-index

A lightweight [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) plugin to show the index of the currently selected entry in the results window. Designed for easy integration via `lazy.nvim` or `require`.

---

## Features

* Displays the current selection index as **virtual text** or **virt_lines**.
* Updates automatically when moving through Telescope results.
* Configurable position: `overlay`, `right_align`, `eol`, `top`, `down`.
* Lightweight and easy to add to any Neovim setup.
* No extra Telescope extensions required.

---

## Installation

### Using lazy.nvim

```lua
{
  "StefanBartl/telescope-selected-index",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup({
      extensions = {
        selected_index = opts,
      },
    })
    telescope.load_extension("selected_index")
  end,
  opts = {
    position = "right",
  },
}
```

### Using packer.nvim

```lua
use {
    "StefanBartl/telescope-selected-index",
    after = "telescope.nvim",  -- Load after telescope
    config = function()
        require("telescope_selected_index").setup({
            position = "right_align",  -- optional, default is "right_align"
        })
    end
}
```

---

## Usage

After installation, the plugin automatically attaches to all Telescope pickers. The index of the currently selected entry will appear on the **current line** in the results window.

### Options

| Option     | Type   | Default         | Description                                                                                        |
| ---------- | ------ | --------------- | -------------------------------------------------------------------------------------------------- |
| `position` | string | `"right_align"` | Where to display the index. Valid values: `"overlay"`, `"right_align"`, `"eol"`, `"top"`, `"down"` |

```lua
require("telescope-selected-index").setup({
    position = "right_align"
})
```

---

## Why `right_align` is generally the best option

### The Problem

Ideally, the numbering would be inserted directly by the Telescope `entry_maker`. This would guarantee exact alignment and integration. However, modifying the `entry_maker` is complex and requires deep changes to Telescope itself. Doing it via Neovim configuration is cumbersome and prone to breakage.

This plugin uses **Neovim extmarks** to draw the numbering "on top" of the results buffer. While effective, this introduces layout challenges depending on the chosen position:

-----------------------------+
| overlay                     | ← Draws directly at the start of each line
|                             |   → First few characters may be obscured
+-----------------------------+
|              eol            | ← Draws at the end of each line
|                             |   → Lines of varying length cause numbering to jump left and right
+-----------------------------+
| top (above=true)            | ← Draws above each line
|                             |   → The first line has no line above, numbering invisible
+-----------------------------+
|                             | ← Draws below each line
|  down (above=false)         |   → The last line has no line below, numbering invisible
+-----------------------------+
|         right_align / right | ← Draws at a fixed right-hand column
|                             |   → **Always visible, in a stable column, minimally overlapping very long lines**
+-----------------------------+

**Summary:**
  - `overlay` obscures the start of lines.
  - `eol` jumps left/right with line length.
  - `top`/`down` hide the first or last line.
  - **`right_align` / `right`** ensures consistent visibility and alignment in a single column, overwriting only a few characters if a line is extremely long.

For these reasons, `right_align` is recommended as the default and most reliable option.

---

## Development

* Use `:Telescope find_files` or any other picker.
* Navigate with arrow keys or `<C-n>/<C-p>` in insert mode.
* The index will update dynamically as you move the selection.

---

## Contributing

1. Fork the repository.
2. Make your changes inside the `lua/telescope_selected_index/` folder.
3. Test locally with `lazy.nvim` or manually requiring the plugin.
4. Submit a pull request.

---

## License

MIT License

---

If desired, I can also create an **ASCII diagram illustrating the exact extmark overlay positions** for all options to make it even clearer in the README. Do you want me to add that?
