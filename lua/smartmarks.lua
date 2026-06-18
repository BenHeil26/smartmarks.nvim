local M = {}

function M.open_window()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "Hello World" })

  local w1 = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 10,
    height = 10,
    anchor = "NW",
    style = "minimal",
  })
end

function M.setup(opts)
  opts = opts or {};

  vim.api.nvim_create_user_command("OpenWindow", M.open_window, opts)

  local keymap = opts.keymap or "<leader>ow"

  vim.keymap.set("n", keymap, M.open_window)
end

return M
