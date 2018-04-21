local a = vim.api
i = require('inspect')
if the_id == nil then
    the_id = a.nvim_buf_add_highlight(0, 0, "", 0, 0, 0)
end
function myhandler(success,data)
    ts = success
    td = data
    a.nvim_buf_clear_highlight(0, the_id, 0, -1)
    if not success then
      return
    end
    for _, msg in ipairs(data.diagnostics) do
      local range = msg.range
      range._end = range['end']
      if range._end.line ~= range.start.line then
        range._end.line = range.start.line
        range._end.character = -1
      end
      a.nvim_buf_add_highlight(0, the_id, "LspLocation", range.start.line, range.start.character, range._end.character)
      local kind
      if msg.severity == 1 then
          kind = "LspError"
      else
          kind = "LspWarning"
      end
      a.nvim_buf_set_eol_text(0, the_id, kind, range.start.line, '  ▶ '..msg.message)
    end

end
require('lsp.callbacks').callbacks.textDocument.publishDiagnostics = myhandler
