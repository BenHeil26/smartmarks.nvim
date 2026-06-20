local M = {
  win = nil,
  ns = vim.api.nvim_create_namespace("smartmarks"),
  group = vim.api.nvim_create_augroup("smartmarks", { clear = true })
}

local hl_groups = {
  "OkMsg",
  "Type",
  "String",
  "Boolean",
  "WarningMsg",
  "Title",
  "Function",
}

function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)

  local marks = vim.api.nvim_exec2("marks", { output = true }) -- gets all marks for this buffer

  local marks_tbl = vim.split(marks.output, "\n", { trimempty = true })
  local tbl, width = M.process_marks_table(marks_tbl)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, marks_tbl)

  for i = 0, #tbl do
    vim.api.nvim_buf_set_extmark(buf, M.ns, i, 0, {
      line_hl_group = hl_groups[i % #hl_groups + 1],
    })
  end

  return vim.api.nvim_open_win(buf, false, {
    relative = 'cursor',
    row = 1,
    col = 1,
    width = width + 2,
    height = #tbl,
    anchor = "NW",
    style = "minimal",
    title = "marks",
    title_pos = "left",
    border = "single",
    focusable = false,
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

function M.close_window()
  vim.on_key(nil, M.ns)

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
  end

  M.win = nil
end

function M.handle_mark()
  -- open the window and wait for the next input
  vim.schedule(function()
    M.win = M.open_window()

    vim.cmd("redraw")

    vim.api.nvim_clear_autocmds({ group = M.group })

    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      group = M.group,
      once = true,
      callback = function()
        vim.schedule(M.close_window)
      end,
    })
  end)
end

function M.setup(opts)
  opts = opts or {};
  vim.keymap.set({ "n", "o" }, "ma", M.handle_mark, { silent = true })
end

return M
