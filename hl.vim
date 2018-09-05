hi LspWarning guifg=#aaaa00
hi LspError guifg=#ee2222
hi LspOtherMsg guifg=#888888
hi LspLocation gui=underline
hi LspLocationError gui=underline guibg=#660000
hi LspLocationWarning gui=underline guibg=#222200

augroup lsptest
au!
"au TextChangedI *.c nested call luaeval("require('lsp.plugin').client.request_autocmd('textDocument/didChange')")
au TextChangedI *.c lua require('lsp.plugin').client.request_async('textDocument/didChange')
augroup END
nmap <LocalLeader>s :lua lsptest_signature()<cr>
