--- @class SMOptions
--- @field hl_groups string[] the hightlight groups to use for your mark color codes
--- @field show_virtual boolean show virtual text for marks in current file (defaults true)
--- @field current_file_only boolean only show marks for current file in float window
--- @field float_options vim.api.keyset.win_config floating window options
local SMOptions = {}

function SMOptions:new(opts)
  local instance = setmetatable({}, self)
  self.__index = self
  instance.hl_groups = opts.hl_groups or {
    "OkMsg",
    "Type",
    "String",
    "Boolean",
    "WarningMsg",
    "Title",
    "Function",
  }
  instance.show_virtual = opts.show_virtual
  instance.current_file_only = opts.current_file_only
  instance.float_options = opts.float_options or {
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
  return instance
end

return SMOptions
