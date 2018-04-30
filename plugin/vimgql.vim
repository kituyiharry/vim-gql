if exists("loaded_vim_gql")
  finish
endif

let loaded_vim_gql = 1
let g:gql_endpoint = "localhost:4000/graphql"
let g:query = " --data '{ \"query\" : \" { allSilos { id organization } }\"  }' "

function! GQLGraphiQL()
  " Open a new split and set it up.
  call s:CreateInteractiveWindow()
  call s:CreateResponseWindow()
endfunction

function! s:ExecuteQuery(query)
  let bytecode = 
        \ system("curl -s -X POST -H 
        \ 'Content-Type: application/json'" .
        \  a:query . g:gql_endpoint . 
        \ " | prettier --parser json --stdin")
  return bytecode
endfunction

function! s:CreateInteractiveWindow()
  belowright 10sp __GQLRsp__
  setlocal filetype=graphql
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  set nobuflisted
endfunction

function! s:CreateResponseWindow()
  rightbelow vsp __Response__
  normal! ggdG
  setlocal filetype=json
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  " setlocal nonumber
  set nobuflisted
endfunction

function! s:GiveFocusToResponseWindow()
  let curr_buf =  bufwinnr("%")
  let resp_buf =  bufwinnr("__Response__")
  if curr_buf == resp_buf
    "we are already in
  elseif resp_buf == -1
    call s:CreateResponseWindow()
  else
    execute resp_buf . " wincmd w"
  endif
endfunction

function! s:GiveFocusToInteractiveWindow()
  let curr_buf =  bufwinnr("%")
  let resp_buf =  bufwinnr("__GQLRsp__")
  if curr_buf == resp_buf
    "we are already in
  elseif resp_buf == -1
    call s:CreateInteractiveWindow()
  else
    execute resp_buf . " wincmd w"
  endif
endfunction

function! s:AppendResponseToBuffer(response) 
  " Insert the bytecode.
  call s:GiveFocusToResponseWindow()
  normal! ggdG
  call append(0, split(a:response, '\v\n'))
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
  call g:GQLCloseResponseWindow()
endfunction

function! GQLExecuteUnderCursor() range
  let s:queryString = " --data '{ \"query\" : \" "
  for line_number in range(a:firstline,a:lastline)
    let content = escape(getline(line_number),'"')
    let s:queryString = s:queryString . content
  endfor
  let s:queryString = s:queryString . " \" }' "
  echom s:queryString
  call s:AppendResponseToBuffer(s:ExecuteQuery(s:queryString))
endfunction
