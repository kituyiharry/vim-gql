if exists("loaded_vim_gql")
  finish
endif

let loaded_vim_gql = 1
let g:gql_endpoint = "localhost:4000/graphql"
let g:query = " --data '{ \"query\" : \" { allSilos { id organization } }\"  }' "

function! GQLGraphiQL()
  " Get the bytecode.
  let bytecode = 
        \ system("curl -s -X POST -H 
        \ 'Content-Type: application/json'" .
        \  g:query . g:gql_endpoint . 
        \ " | prettier --parser json --stdin")
  
  " Open a new split and set it up.
  call s:CreateInteractiveWindow()

  "vsp Response
  rightbelow vsp __Response__
  normal! ggdG
  setlocal filetype=json
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nonumber
  set nobuflisted
  " Insert the bytecode.
  call append(0, split(bytecode, '\v\n'))
endfunction

function! s:CreateInteractiveWindow()
  belowright 10sp __GQLRsp__
  setlocal filetype=json
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nonumber
  setlocal noswapfile
  set nobuflisted
endfunction

function! GQLCloseResponseWindow()
  let resp_buf =  bufwinnr("__Response__")
  if resp_buf == -1
    "resp_buf close
  else
    execute resp_buf . " close"
  endif
endfunction

function! GQLCloseInteractiveWindow()
  let int_buf = bufwinnr("__GQLRsp__")
  if int_buf == -1
    "resp_buf close
  else
    execute int_buf . " close"
  endif
endfunction

function! GQLExit()
  call g:GQLCloseInteractiveWindow()
  call g:GQLCloseInteractiveWindow()
endfunction
