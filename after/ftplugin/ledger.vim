" ledger.vim: settings for Leger journal files

if exists("SuperTabSet*")
  call SuperTabSetDefaultCompletionType("<c-x><c-o>")
endif

nnoremap <buffer> <silent> <leader>ll   :<C-u>Ledger balance<CR>
nnoremap <buffer> <silent> <leader>lr   :<C-u>Register<CR>
nnoremap <buffer> <silent> <leader>la   :<C-u>LedgerAlign<CR>
vnoremap <buffer> <silent> <leader>la   :<C-u>LedgerAlign<CR>

nnoremap <buffer> <silent> <leader>le   :<C-u>call ledger#entry()<CR>
nnoremap <buffer> <silent> <leader>lc   :<C-u>call ledger#transaction_state_set(line('.'), '*')<CR>
