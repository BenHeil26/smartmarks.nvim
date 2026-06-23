local Mark      = require("marks")
local Windows   = require("windows")
local Virtuals  = require("virtual_text")
local SMOptions = require("sm_options")

local M         = {
  ns = vim.api.nvim_create_namespace("smartmarks"),
  group = vim.api.nvim_create_augroup("smartmarks", { clear = true }),
  --- @type SMOptions
  options = nil
}

function M.get_marks()
  local marks = vim.api.nvim_exec2("marks", { output = true })
  local marks_tbl = vim.split(marks.output, "\n", { trimempty = true })

  local ret = {}

  for i = 2, #marks_tbl do
    table.insert(ret, Mark:new(marks_tbl[i], M.options.hl_groups[i % #M.options.hl_groups + 1]))
  end

  return ret
end

function M.show_marks()
  -- open the window and wait for the next input
  vim.schedule(function()
    Windows.open(M.get_marks(), M.ns, M.options.float_options)

    vim.cmd("redraw")

    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      group = M.group,
      once = true,
      callback = function()
        Windows.close(M.ns)
      end,
    })
  end)
end

--- Configure the plugin settings
--- @param opts SMOptions
function M.setup(opts)
  M.options = SMOptions:new(opts)

  if M.options.show_virtual then
    vim.api.nvim_create_autocmd({ "CursorMoved", "MarkSet" }, {
      group = M.group,
      callback = function()
        Virtuals.show(M.get_marks(), M.ns)
      end
    })
  end

  vim.keymap.set("n", "<leader>ma", M.show_marks, { silent = true })
end

return M
