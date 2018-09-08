" only load if lsp is available
try
  lua require'lsp.client'
catch
  finish
endtry


hi LspWarning guifg=#aaaa00
hi LspError guifg=#ee2222
hi LspOtherMsg guifg=#888888
hi LspLocation gui=underline
hi LspLocationError gui=underline guibg=#660000
hi LspLocationWarning gui=underline guibg=#222200

lua lspext = require'lspext'

" TODO: should be a standardized lua interface for this:
augroup lspext
au!
au TextChangedI *.c lua require'lsp.plugin'.client.request_async('textDocument/didChange')
augroup END

map <Plug>(lspext-signature) <cmd>lua lspext.signature()<cr>
map! <Plug>(lspext-signature) <cmd>lua lspext.signature()<cr>
