local helpers = {}

-- Simple split: returns all fields (including empty ones) using a plain separator.
function helpers.split(s, sep)
  if type(s) ~= "string" or type(sep) ~= "string" then return {} end

  if sep == "" then
    local t = {}

    for i = 1, #s do t[#t + 1] = s:sub(i, i) end

    return t
  end

  local t = {}
  local start = 1

  while true do
    local i, j = s:find(sep, start, true)

    if not i then
      t[#t + 1] = s:sub(start)
      break
    end

    t[#t + 1] = s:sub(start, i - 1)
    start = j + 1
  end

  return t
end

return helpers
