local table_helpers = {}

--- executes the specified function over each element and returns the resultant table
--- @param self table the table to iterate over
--- @param fun function the function to execute for each element
--- @return table
function table_helpers.map(self, fun)
  local t = {}
  for k, v in pairs(self) do
    t[k] = fun(v)
  end
  return t
end

return table_helpers
