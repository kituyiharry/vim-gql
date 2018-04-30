if exists("loaded_vim_gql")
  finish
endif

let loaded_vim_gql = 1

if !exists("gql_endpoint")
  let g:gql_endpoint = "localhost:4000/graphql"
endif

command! -nargs=0 GQLGraphiQL call vimgql#GQLGraphiQL()
