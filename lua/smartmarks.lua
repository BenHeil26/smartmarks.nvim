local M = {}

function M.open_window()
  local w1 = vim.api.nvim_open_win(0, false,
    { relative = 'win', row = 3, col = 3, width = 40, height = 4 })
end

function M.setup(opts)
  opts = opts or {};

  vim.api.nvim_create_user_command("OpenWindow", M.open_window, opts)

  local keymap = opts.keymap or "<leader>ow"

  vim.keymap.set("n", keymap, "OpenWindow")
end

return M
