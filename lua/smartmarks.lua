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

  local marks = vim.api.nvim_command_output(":marks") -- gets all marks for this buffer

  local marks_tbl = split(marks, "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, marks_tbl)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 50,
    height = 10,
    anchor = "NW",
    style = "minimal",
  })

  M.close_on_input(win, {})
end

function M.close_on_input(win, opts)
  opts = opts or {}
  win = win or vim.api.nvim_get_current_win()

  local closed = false

  -- Delay enabling the handler briefly so the key that opened the float
  -- doesn't close it immediately.
  vim.defer_fn(function()
    local handler

    handler = function(_)
      -- schedule to avoid running during input processing
      vim.schedule(function()
        if closed then return end

        if not vim.api.nvim_win_is_valid(win) then
          closed = true
          -- unregister global handler
          vim.on_key(nil)
          return
        end

        -- try to close (ignore errors)
        pcall(vim.api.nvim_win_close, win, true)
        closed = true

        -- unregister global handler
        vim.on_key(nil)
      end)
    end

    -- install the global on-key handler
    vim.on_key(handler)
  end, 10)
end

function M.setup(opts)
  opts = opts or {};

  vim.api.nvim_create_user_command("OpenWindow", M.open_window, opts)

  local keymap = opts.keymap or "<leader>ow"

  vim.keymap.set("n", keymap, M.open_window)
end

return M
