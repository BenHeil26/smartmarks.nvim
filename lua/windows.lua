local table_helpers = require("table_helpers")


local Windows = {
  buf = nil,
  win = nil,
}

--- Opens a window with the specified mark data
--- @param marks Mark[] an array of marks
--- @param ns integer the id of the namespace to use
function Windows.open(marks, ns)
  Windows.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(Windows.buf, 0, -1, true, table_helpers.map(marks, function(v)
    return v.text
  end))

  local width = 0
  for i, mark in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(Windows.buf, ns, i, 0, {
      line_hl_group = mark.hl_group,
    })

    if #mark.text > width then width = #mark.text end
  end

  Windows.win = vim.api.nvim_open_win(Windows.buf, false, {
    relative = 'cursor',
    row = 1,
    col = 1,
    width = width + 2,
    height = #marks,
    anchor = "NW",
    style = "minimal",
    title = "marks",
    title_pos = "left",
    border = "single",
    focusable = false,
  })
end

function Windows.close(ns)
  vim.on_key(nil, ns)

  if Windows.win and vim.api.nvim_win_is_valid(Windows.win) then
    vim.api.nvim_win_close(Windows.win, true)
  end

  Windows.win = nil
end

return Windows
