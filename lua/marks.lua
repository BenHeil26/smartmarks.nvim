--- @class Mark
--- @field id string the symbol this mark uses
--- @field line integer the line number of this mark
--- @field col integer the column number for this mark
--- @field text string the text from the line this mark points to
--- @field hl_group string the highlight group for this mark
local Mark = {}

--- Creates a new mark from a string representation of it
--- @param s string a string of the form id line col text
--- @param hl_group string a string hightlight group name
--- @return Mark a new mark
function Mark:new(s, hl_group)
  local instance = setmetatable({}, self)
  self.__index = self
  hl_group = hl_group or "None"

  local pattern = "(.)%s+(%d+)%s+(%d+)%s+(.*)"
  local id, line, col, text = s:match(pattern)

  instance.id = id
  instance.line = tonumber(line) or 0
  instance.col = tonumber(col) or 0
  instance.text = text
  instance.hl_group = hl_group

  return instance
end

return Mark
