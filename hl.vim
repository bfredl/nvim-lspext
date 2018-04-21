hi LspWarning guifg=#aaaa00
hi LspError guifg=#ee2222
hi LspLocation gui=underline
au TextChangedI *.c nested call luaeval("require('lsp.plugin').client.request_autocmd('textDocument/didChange')")
nmap <LocalLeader>s :lua lsptest_signature()<cr>
