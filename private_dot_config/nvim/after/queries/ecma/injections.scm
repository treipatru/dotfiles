; extends

; graphql(`...`) (graphql-codegen client preset)
(call_expression
  function: (identifier) @_name
  (#eq? @_name "graphql")
  arguments: (arguments
    (template_string) @injection.content)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "graphql"))

; /* gql */ `...` or /* GraphQL */ `...`
((comment) @_comment
  .
  (template_string) @injection.content
  (#any-of? @_comment "/* gql */" "/* GraphQL */")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "graphql"))
