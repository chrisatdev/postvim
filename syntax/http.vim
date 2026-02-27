" Vim syntax file for .http files (REST Client format)
" Language: HTTP Request
" Maintainer: chrisatdev

if exists("b:current_syntax")
  finish
endif

" HTTP Methods
syn keyword httpMethod GET POST PUT DELETE PATCH HEAD OPTIONS CONNECT TRACE
hi def link httpMethod Statement

" Comment lines (###)
syn match httpComment "^###.*$"
hi def link httpComment Comment

" URLs
syn match httpUrl "\(https\?\|ftp\)://[^ ]*"
hi def link httpUrl Underlined

" Headers (Key: Value)
syn match httpHeader "^[A-Za-z-]\+:"
hi def link httpHeader Type

" Header values
syn match httpHeaderValue ":\s*\zs.*$"
hi def link httpHeaderValue String

" Variables {{variable}}
syn match httpVariable "{{\s*[^}]\+\s*}}"
hi def link httpVariable Identifier

" JSON body (simple highlighting)
syn region httpJsonBody start="{" end="}" contained contains=httpJsonKey,httpJsonString,httpJsonNumber
syn match httpJsonKey /"\([^"]\)*"\s*:/ contained
syn region httpJsonString start=/"/ skip=/\\"/ end=/"/ contained
syn match httpJsonNumber /\d\+/ contained
hi def link httpJsonKey Type
hi def link httpJsonString String
hi def link httpJsonNumber Number

" Status codes in responses
syn match httpStatus "HTTP/\d\.\d\s\+\d\+"
hi def link httpStatus Special

let b:current_syntax = "http"
