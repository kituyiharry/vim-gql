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
  if bufwinnr("__Response__") == -1
    belowright 10sp __GQLRsp__
    setlocal filetype=graphql
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    set nobuflisted
  else
    call s:GiveFocusToInteractiveWindow()
  endif
endfunction

function! s:CreateResponseWindow()
  if bufwinnr("__Response__") == -1
    rightbelow vsp __Response__
    normal! ggdG
    setlocal filetype=json
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    " setlocal nonumber
    set nobuflisted
  else
    call s:GiveFocusToResponseWindow()
  endif
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

function! s:AppendResponseToInteractiveWindow(response) 
  " Insert the bytecode.
  call s:GiveFocusToInteractiveWindow()
  if len(a:response) > 0
    normal! ggdG
    for aline in a:response
      "call append(line('$'), split(line, '\v\n'))
      call append(line('$'), aline)
    endfor
  endif
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
  let s:raw = getline(a:firstline,a:lastline)
  for line_number in range(a:firstline,a:lastline)
    let content = getline(line_number)
    "let s:raw = s:raw . content
    let s:queryString = s:queryString . escape(content,'"')
  endfor
  let s:queryString = s:queryString . " \" }' "
  "echom s:queryString
  call s:AppendResponseToInteractiveWindow(s:raw)
  call s:AppendResponseToBuffer(s:ExecuteQuery(s:queryString))
endfunction

function! GQLInteractiveWindowQueryExecute()
  let s:queryString = " --data '{ \"query\" : \" "
  let lines = getbufline(bufnr("__GQLRsp__"),1,"$") 
  for aline in lines
    let s:queryString = s:queryString . escape(aline,'"')
  endfor
  let s:queryString = s:queryString . " \" }' "
  call s:AppendResponseToBuffer(s:ExecuteQuery(s:queryString))
endfunction
