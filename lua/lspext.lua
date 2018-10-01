local a = vim.api
local client = require'lsp.plugin'.client
--i = require'inspect'

-- TODO: use named namespaces for safe reloading
if __lspext_ns == nil then
    __lspext_ns = a.nvim_buf_add_highlight(0, 0, "", 0, 0, 0)
end
local my_ns = __lspext_ns

local protocol = require'lsp.protocol'
local MessageType = protocol.MessageType

local function on_diagnostics(success, data)
  a.nvim_buf_clear_highlight(0, my_ns, 0, -1)
  if not success then
    return
  end
  local last_line, last_severity = -1, -1
  for _, msg in ipairs(data.diagnostics) do
    local range = msg.range
    range._end = range['end']
    if range._end.line ~= range.start.line then
      range._end.line = range.start.line
      range._end.character = -1
    end

    if last_line == range.start.line and msg.severity > last_severity then
      goto continue
    end
    last_line, last_severity = range.start.line, msg.severity

    if a.nvim_buf_set_virtual_text ~= nil then
      local msg_hl
      if msg.severity == MessageType.Error then
        msg_hl = "LspError"
      elseif msg.severity == MessageType.Warning then
        msg_hl = "LspWarning"
      else
        msg_hl = "LspOtherMsg"
      end
      a.nvim_buf_set_virtual_text(0, my_ns, range.start.line, {{'▶ '..msg.message, msg_hl}}, {})
    else
      -- FIXME: set_eol_text has a bug that a highlight at $ will "bleed" into the
      -- after-eol message, so disable this when eol_text is used
      if msg.severity == MessageType.Error then
        loc_hl = "LspLocationError"
      elseif msg.severity == MessageType.Warning then
        loc_hl = "LspLocationWarning"
      end
    end


    local loc_hl = "LspLocation"
    a.nvim_buf_add_highlight(0, my_ns, loc_hl, range.start.line, range.start.character, range._end.character)
    ::continue::
  end
end

-- TODO: this is not safe for reloading, allow to pass my_ns ?
local callbacks = require'lsp.callbacks'
callbacks.add_callback('textDocument/publishDiagnostics', on_diagnostics)

-- not very good yet (should use floats or something),
-- currently just to test async requests...
local function on_signature(success,data)
    ts = success
    td = data
    if #data.signatures > 0 then
        -- TODO: activeSignature
        local sig = data.signatures[1]
        _thesig = sig.label
        a.nvim_command("echo luaeval('_thesig')")
    end
end

local lspext = {}

function lspext.signature()
  client.request_async("textDocument/signatureHelp", {}, on_signature, nil)
end

return lspext

