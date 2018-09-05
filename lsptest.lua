local a = vim.api
local client = require('lsp.plugin').client
i = require('inspect')
if the_id == nil then
    the_id = a.nvim_buf_add_highlight(0, 0, "", 0, 0, 0)
end

-- FYY
local protocol = require('lsp.protocol')
local lsp_util = require('lsp.util')
local util = require('neovim.util')
the_old = function(success, data)
  if not success then
    error_callback('textDocument/publishDiagnostics', data)
    return nil
  end

  local loclist = {}

  for _, diagnostic in ipairs(data.diagnostics) do
    local range = diagnostic.range
    local severity = diagnostic.severity or protocol.DiagnosticSeverity.Information

    local message_type
    if severity == protocol.DiagnosticSeverity.Error then
      message_type = 'E'
    elseif severity == protocol.DiagnosticSeverity.Warning then
      message_type = 'W'
    else
      message_type = 'I'
    end

    -- local code = diagnostic.code
    local source = diagnostic.source or 'lsp'
    local message = diagnostic.message

    table.insert(loclist, {
      lnum = range.start.line + 1,
      col = range.start.character + 1,
      text = '[' .. source .. ']' .. message,
      filename = lsp_util.get_filename(data.uri),
      ['type'] = message_type,
    })
  end

  local result = vim.api.nvim_call_function('setloclist', {0, {}, 'r', {items=loclist, context='lsp'}})

  if loclist ~= {} and not util.is_loclist_open() then
    -- vim.api.nvim_command('lopen')
    -- vim.api.nvim_command('wincmd p')
  end

  return result
end

if the_old == nil then
    the_old = require('lsp.callbacks').callbacks.textDocument.publishDiagnostics
end

function myhandler(success,data)
    if the_old ~= nil then
      --pcall(the_old,success,data)
      the_old(success, data)
    end
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

function on_signature(success,data)
    ts = success
    td = data
    if #data.signatures > 0 then
        -- TODO: activeSignature
        local sig = data.signatures[1]
        _thesig = sig.label
        a.nvim_command("echo luaeval('_thesig')")
    end
end

function lsptest_signature()
    client.request_async("textDocument/signatureHelp", {}, on_signature, nil)
end


require('lsp.callbacks').callbacks.textDocument.publishDiagnostics = myhandler
