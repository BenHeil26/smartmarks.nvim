local M = {
  win = nil,
  ns = vim.api.nvim_create_namespace("smartmarks"),
  group = vim.api.nvim_create_augroup("smartmarks", { clear = true }),
  --- @type Mark[]
  cur_marks = {},
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

-- TODO: refactor this to share marks state with included line numbers and highlight group
function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)

  local tbl, width = M.process_marks_window(M.get_marks())

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, tbl)

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

function M.set_virtual(buf)
  local sign_map = M.process_marks_virtual(M.get_marks())
  local i = 1

  local extmarks = vim.api.nvim_buf_get_extmarks(buf, M.ns, 0, -1, {})

  for _, em in ipairs(extmarks) do
    vim.api.nvim_buf_del_extmark(buf, M.ns, em[1])
  end

  for mark, l in pairs(sign_map) do
    local line = tonumber(l) - 1

    if line <= vim.api.nvim_buf_line_count(buf) then
      vim.api.nvim_buf_set_extmark(buf, M.ns, tonumber(line) or 0, 0, {
        virt_text = { { mark, hl_groups[i % #hl_groups + 1] } },
        virt_text_pos = 'right_align' -- Position of the virtual text
      })
    end

    i = i + 1
  end
end

function M.get_marks()
  local marks = vim.api.nvim_exec2("marks", { output = true }) -- gets all marks for this buffer
  return vim.split(marks.output, "\n", { trimempty = true })
end

function M.process_marks_virtual(marks_tbl)
  local seen_marks = {}
  local ret = {}
  local pattern = "(.)%s+(%d+)%s+(%d+)%s+(.*)"

  for i = 2, #marks_tbl do
    local m, l, c, txt = marks_tbl[i]:match(pattern)

    -- deduplicate marks
    local key = l .. " " .. c
    if seen_marks[key] == nil then
      seen_marks[key] = i
    else
      goto continue
    end

    -- remove marks from other files
    if txt:match("^%.?[%.%.]?/?[%w%d_%-%.+/]+/%w+%.%w+$") then
      goto continue
    end

    ret[m] = l

    ::continue::
  end

  return ret
end

--- processes marks lines to strip unwanted text and filter for current buffer only
--- @param marks_tbl string[]
--- @return string[] marks_tbl the manipulated table
--- @return integer max_width the max line length
function M.process_marks_window(marks_tbl)
  local to_remove = { 1 } -- always remove the header line
  local seen_marks = {}
  local pattern = "(.)%s+(%d+)%s+(%d+)%s+(.*)"
  local max_width = 0

  for i = 2, #marks_tbl do
    local m, l, c, txt = marks_tbl[i]:match(pattern)


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

  for _, mark in ipairs(marks_tbl) do
    -- track max width
    if #mark > max_width then max_width = #mark end
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

function M.show_marks()
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

  hl_groups = opts.hl_groups or hl_groups

  vim.api.nvim_create_autocmd({ "BufEnter", "MarkSet" }, {
    group = M.group,
    callback = function()
      M.set_virtual(vim.api.nvim_get_current_buf())
    end
  })

  vim.keymap.set("n", "<leader>ma", M.show_marks, { silent = true })
end

return M
