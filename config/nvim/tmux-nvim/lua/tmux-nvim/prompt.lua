local M = {}

function M.format(items, opts)
  opts = opts or {}
  local header = "- Review the comments below and act accordingly"
  if opts.header_context then header = header .. " (" .. opts.header_context .. ")" end
  local lines = { header, "" }
  for i, item in ipairs(items) do
    local c = item.comment
    table.insert(lines, string.format("%d. %s:%d-%d", i, c.file, c.start_line, c.end_line))
    for j = 1, math.min(3, #(item.snippet or {})) do
      table.insert(lines, "   > " .. item.snippet[j])
    end
    table.insert(lines, "")
    table.insert(lines, "[My Comment]")
    for _, line in ipairs(vim.split(c.text, "\n", { plain = true })) do
      table.insert(lines, line)
    end
    table.insert(lines, "")
  end
  return table.concat(lines, "\n")
end

return M
