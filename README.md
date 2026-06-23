## `smartmarks.nvim`
A simple plugin that let's you view and organize marks with ease. 
## Install
Lazy
```lua
{
  "BenHeil26/smartmarks.nvim",
  config = function()
    require('smartmarks').setup({})
  end
}
```

## Features
- Virtual Text shows current marks in real time
- Floating window displays mark preview Text
- Color coding for ease of use
- Customization options

## Configuration Options 
```lua
-- default options, pass this in to override
local options = {
    hl_groups = {
        "OkMsg",
        "Type",
        "String",
        "Boolean",
        "WarningMsg",
        "Title",
        "Function",
    },
    show_virtual = true,
    current_file_only = false,
    float_options = {
        relative = 'cursor',
        row = 1,
        col = 1,
        anchor = "NW",
        style = "minimal",
        title = "marks",
        title_pos = "left",
        border = "single",
        focusable = false,
    }
}

```

## Next Up
- make managing marks better
- manage automatically created marks 
