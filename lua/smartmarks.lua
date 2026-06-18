local M = {}

-- Simple split: returns all fields (including empty ones) using a plain separator.
local function split(s, sep)
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

function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)

  local marks = vim.api.nvim_exec2("marks", { output = true }) -- gets all marks for this buffer

  local marks_tbl = split(marks.output, "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, marks_tbl)

  return vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 75,
    height = #marks_tbl,
    anchor = "NW",
    style = "minimal",
    title = "marks",
    title_pos = "left",
    border = "single"
  })
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
