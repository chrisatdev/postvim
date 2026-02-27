" PostVim - HTTP client for Neovim
" Author: chrisatdev
" License: MIT

if exists('g:loaded_postvim')
  finish
endif
let g:loaded_postvim = 1

" Setup PostVim with default configuration if not already setup
lua << EOF
local ok, postvim = pcall(require, 'postvim')
if ok then
  -- Initialize with empty config (uses defaults)
  -- Users can override with require('postvim').setup({...}) in their init.lua
  postvim.setup({})
end
EOF
