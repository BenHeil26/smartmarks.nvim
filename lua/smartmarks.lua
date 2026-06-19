local helpers = require("helpers")

local M = {}

function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)

  local marks = vim.api.nvim_exec2("marks", { output = true }) -- gets all marks for this buffer

  local marks_tbl = helpers.split(marks.output, "\n")
  local tbl, width = M.process_marks_table(marks_tbl)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, marks_tbl)

  return vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 1,
    width = width + 2,
    height = #tbl,
    anchor = "NW",
    style = "minimal",
    title = "marks",
    title_pos = "left",
    border = "single"
  })
end

--- processes marks lines to strip unwanted text and filter for current buffer only
--- @param marks_tbl string[]
--- @return string[] marks_tbl the manipulated table
--- @return integer max_width the max line length
function M.process_marks_table(marks_tbl)
  local to_remove = { 1 } -- always remove the header line
  local seen_marks = {}
  local pattern = "(.)%s+(%d+)%s+(%d+)%s+(.*)"
  local max_width = 0

  for i = 2, #marks_tbl do
    local m, l, c, txt = marks_tbl[i]:match(pattern)

    -- track max width
    if #txt > max_width then max_width = #txt end

    -- deduplicate marks
    local key = l .. " " .. c
    if seen_marks[key] == nil then
      seen_marks[key] = i
    else
      table.insert(to_remove, i)
    end

    -- remove the line and column number from the line
    marks_tbl[i] = m .. " " .. txt

    -- remove marks from other files
    if txt:match("^%.?[%.%.]?/?[%w%d_%-%.+/]+/%w+%.%w+$") then
      table.insert(to_remove, i)
    end
  end

  for i = #to_remove, 1, -1 do
    table.remove(marks_tbl, to_remove[i])
  end

  return marks_tbl, max_width
end

function M.close_window(win)
  vim.api.nvim_win_close(win, true);
end

function M.setup(opts)
  opts = opts or {};

  vim.api.nvim_create_user_command("OpenWindow", M.open_window, opts)

  local keymap = opts.keymap or "<leader>ow"

  vim.keymap.set("n", keymap, function()
    local win = M.open_window()

    vim.api.nvim_exec2("redraw", {})

    vim.fn.getcharstr()

    M.close_window(win)
  end)
end

return M
