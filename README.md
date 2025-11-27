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
    "username/telescope-selected-index",
    config = function(_, opts)
        require("telescope-selected-index").setup(opts)
    end,
    opts = {
        position = "right",  -- optional, default is "right"
    }
}
```

### Using packer.nvim

```lua
use {
    "username/telescope-selected-index",
    config = function()
        require("telescope-selected-index").setup({
            position = "right"
        })
    end
}
```

---

## Usage

After installation, the plugin automatically attaches to all Telescope pickers. The index of the currently selected entry will appear on the **current line** in the results window.

### Options

| Option     | Type   | Default   | Description                                                                                        |
| ---------- | ------ | --------- | -------------------------------------------------------------------------------------------------- |
| `position` | string | `"right"` | Where to display the index. Valid values: `"overlay"`, `"right_align"`, `"eol"`, `"top"`, `"down"` |

```lua
require("telescope-selected-index").setup({
    position = "overlay"
})
```

---

## Folder Structure

```
telescope-selected-index/
├── lua/
│   └── telescope_selected_index/
│       ├── selected_index.lua
│       ├── compute.lua
│       ├── move.lua
│       ├── update.lua
│       ├── config.lua
│       └── display/
│           ├── virt_lines.lua
│           └── virt_text.lua
├── README.md
└── plugin/
    └── telescope-selected-index.lua
```

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
