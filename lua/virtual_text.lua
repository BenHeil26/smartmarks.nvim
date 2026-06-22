local Virtuals = {}

--- Sets virtual text for the provided marks in the current buffer
---   does not filter out marks from other files or duplicates
--- @param marks Mark[] an array of marks to show
--- @param ns integer the vim namespace to use
function Virtuals.show(marks, ns)
  local buf = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})

  for _, em in ipairs(extmarks) do
    vim.api.nvim_buf_del_extmark(buf, ns, em[1])
  end

  for _, mark in ipairs(marks) do
    if mark.text:match("^%~?%.?[%.%.]?/?[%w%d_%-%.+/]+%w+%.%w+$") then
      goto continue
    end

    if mark.line <= vim.api.nvim_buf_line_count(buf) then
      vim.api.nvim_buf_set_extmark(buf, ns, mark.line - 1, 0, {
        virt_text = { { mark.id, mark.hl_group } },
        virt_text_pos = 'right_align' -- Position of the virtual text
      })
    end
    ::continue::
  end
end

return Virtuals
