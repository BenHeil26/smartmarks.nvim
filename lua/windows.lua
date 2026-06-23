local table_helpers = require("table_helpers")

local Windows = {
  buf = nil,
  win = nil,
}

--- Opens a window with the specified mark data
--- @param marks Mark[] an array of marks
--- @param ns integer the id of the namespace to use
--- @param opts vim.api.keyset.win_config window options for the floating window
function Windows.open(marks, ns, opts)
  Windows.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(Windows.buf, 0, -1, true, table_helpers.map(marks, function(v)
    return string.format("%s %s", v.id, v.text)
  end))

  local width = 0
  for i, mark in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(Windows.buf, ns, i - 1, 0, {
      line_hl_group = mark.hl_group,
    })

    if #mark.text > width then width = #mark.text end
  end

  opts.width = width + 2
  opts.height = #marks

  Windows.win = vim.api.nvim_open_win(Windows.buf, false, opts)
end

--- closes the window that displays mark data
--- @param ns integer the id of the namespace to use
function Windows.close(ns)
  vim.on_key(nil, ns)

  if Windows.win and vim.api.nvim_win_is_valid(Windows.win) then
    vim.api.nvim_win_close(Windows.win, true)
  end

  Windows.win = nil
end

return Windows
